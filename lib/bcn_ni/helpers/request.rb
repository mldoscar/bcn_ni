require 'uri'
require 'net/http'
require 'net/https'
require 'nokogiri'
require 'open-uri'
require 'active_support/core_ext/hash'
require 'json'

module BcnNi
  class Request
    @request_url  = nil
    @request_mode = nil
    @exceptions   = nil

    def request_url
      return @request_url
    end

    def request_mode
      return @request_mode
    end

    def exceptions
      return @exceptions
    end

    def initialize(args = {})
      @request_mode = (args[:request_mode] || :scrapping).to_sym
      @exceptions   = []

      case @request_mode
      when :scrapping
        @request_url = "https://www.bcn.gob.ni/estadisticas/mercados_cambiarios/tipo_cambio/cordoba_dolar/mes.php"
      when :soap
        # See 'https://servicios.bcn.gob.ni/Tc_Servicio/ServicioTC.asmx' for more info about how to build a RAW SOAP request
        @request_url = "https://servicios.bcn.gob.ni/Tc_Servicio/ServicioTC.asmx?WSDL"
      else
        raise NotImplementedError, 'Request mode not implemented'
      end
    end

    def exchange_month(year, month)
      begin
        # Evaluate scrapping mode to call the correct method for processing the request
        case request_mode
        when :scrapping
          return scra__exchange_month(year, month)
        when :soap
          return soap__exchange_month(year, month)
        end
      rescue Exception => e
        # Save the exception into the exception list for future error messages or debugging
        @exceptions.push e

        # Return an empty value according to the called method
        return []
      end
    end

    def exchange_day(year, month, day)
      begin
        # Evaluate scrapping mode to call the correct method for processing the request
        case request_mode
        when :scrapping
          return scra__exchange_day(year, month, day)
        when :soap
          return soap__exchange_day(year, month, day)
        end
      rescue Exception => e
        # Save the exception into the exception list for future error messages or debugging
        @exceptions.push e

        # Return an empty value according to the called method
        return nil
      end
    end

    private
      def scra__exchange_month(year, month)
        # Parse the date
        start_date = Date.new(year, month, 1)
        end_date   = start_date.end_of_month

        # Create the arg hash
        args = {
          Fecha_inicial:  start_date,
          Fecha_final:    end_date
        }

        # Generate the full url
        full_url = request_url + '?' + args.to_param
        
        # This loop prevents a random EOFError (main cause is not known yet)
        retries   = 0
        response  = nil
        while true
          # Raise an error if too many retries
          raise StopIteration if retries >= 5

          begin
            response = open(full_url, { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE })
            # Exit loop if response has been assigned
            break
          rescue EOFError => e
            # Sum retry and sleep the thread for a while
            retries += 1
            sleep(2.seconds)
          end
        end

        # Parse the HTML document
        doc = Nokogiri::HTML(response)

        result = []
        # Iterate table
        doc.css('table tr').each_with_index do |row, i|
          next if i.zero?

          # Parse the value
          # (Date is not parsed because it's not given in a correct format, giving the month it in spanish)
          # so, we must assume that dates are given in ascendent sort order
          value = row.css('td')[1].content

          # Push the result into the array
          result.push({ date: start_date + (i - 1).day, value: value.strip.to_f })
        end

        return result
      end

      def scra__exchange_day(year, month, day)
        # Parse the date
        start_date = Date.new(year, month, day)

        # Find the result into the month table
        found_result = scra__exchange_month(year, month).find { |x| x[:date] == start_date }

        # Return the result value
        return (found_result || {})[:value]
      end

      def soap__exchange_day(year, month, day)
        # Build body through a XML envelope
        body          = soap__envelope(soap__letter_exchange_day(year, month, day))
        json_response = soap__request(body)

        # Get the result value
        value_result = json_response['Envelope']['Body']['RecuperaTC_DiaResponse']['RecuperaTC_DiaResult']
        # Parse the result value and finally return it
        return value_result.to_f
      end

      def soap__exchange_month(year, month)
        # Build body through a XML envelope
        body          = soap__envelope(soap__letter_exchange_month(year, month))
        json_response = soap__request(body)

        # Get the result array
        exchange_table = json_response['Envelope']['Body']['RecuperaTC_MesResponse']['RecuperaTC_MesResult']['Detalle_TC']['Tc']

        if exchange_table.present?
          # Parse the table to a custom and better JSON
          # The format example will be: {date: as Date, value: as Float}
          parsed_table = exchange_table.map{ |x| { date: Date.parse(x['Fecha']), value: x['Valor'].to_f } }
          # Sort the parsed table and finally return it
          return parsed_table.sort_by { |x| x[:date] }
        else
          return []
        end
      end

      def soap__request(body)
        # Parse the URI
        uri           = URI.parse(request_url)
        # Create protocol to the URI
        request_engine              = Net::HTTP.new(uri.host, uri.port)
        request_engine.use_ssl      = true
        request_engine.verify_mode  = OpenSSL::SSL::VERIFY_NONE
        request_engine.open_timeout = 15.seconds

        # Create a new POST request as XML content type
        req                 = Net::HTTP::Post.new(uri.path)
        req['Content-Type'] = 'text/xml'

        # Set the request body as a RAW SOAP XML request
        req.body = body
        # Process the request
        res = request_engine.request(req)
        # Get the XML response
        xml_response = res.body

        # Parse to a JSON hash
        return Hash.from_xml(xml_response)
      end

      def soap__envelope(letter)
        envelope = <<EOF
          <?xml version="1.0" encoding="utf-8"?>
          <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Body>
              #{letter}
            </soap:Body>
          </soap:Envelope>
EOF
        return envelope
      end

      def soap__letter_exchange_day(year, month, day)
        letter = <<EOF
          <RecuperaTC_Dia xmlns="http://servicios.bcn.gob.ni/">
            <Ano>#{year}</Ano>
            <Mes>#{month}</Mes>
            <Dia>#{day}</Dia>
          </RecuperaTC_Dia>
EOF
        return letter
      end

      def soap__letter_exchange_month(year, month)
        letter = <<EOF
          <RecuperaTC_Mes xmlns="http://servicios.bcn.gob.ni/">
            <Ano>#{year}</Ano>
            <Mes>#{month}</Mes>
          </RecuperaTC_Mes>
EOF
        return letter
      end

  end
end