require 'uri'
require 'net/http'
require 'net/https'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'open3'
require 'active_support/core_ext/hash'
begin
  require 'active_support/time'
rescue LoadError
end


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
        @request_url = "https://www.bcn.gob.ni/IRR/tipo_cambio_mensual/mes.php"
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

        # Create the arg hash
        args = {
          mes:  start_date.strftime('%m'),
          anio: start_date.strftime('%Y')
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
            response = URI.open(full_url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
            # Exit loop if response has been assigned
            break
          rescue EOFError
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
        body         = soap__envelope(soap__letter_exchange_day(year, month, day))
        xml_response = soap__request(body)
        doc          = Nokogiri::XML(xml_response)

        # Parse the result value and finally return it
        value_result = doc.at_xpath("//*[local-name()='RecuperaTC_DiaResult']")&.text
        return value_result.to_f
      end

      def soap__exchange_month(year, month)
        # Build body through a XML envelope
        body         = soap__envelope(soap__letter_exchange_month(year, month))
        xml_response = soap__request(body)
        doc          = Nokogiri::XML(xml_response)

        # Parse the table to a custom and better JSON
        # The format example will be: {date: as Date, value: as Float}
        exchange_rows = doc.xpath("//*[local-name()='Detalle_TC']/*[local-name()='Tc']")
        parsed_table = exchange_rows.map do |row|
          {
            date: Date.parse(row.at_xpath("*[local-name()='Fecha']")&.text.to_s),
            value: row.at_xpath("*[local-name()='Valor']")&.text.to_f
          }
        end

        # Sort the parsed table and finally return it
        return parsed_table.sort_by { |x| x[:date] }
      end

      def soap__request(body)
        xml_response = begin
          soap__request_with_net_http(body)
        rescue OpenSSL::SSL::SSLError => e
          # BCN SOAP endpoint currently negotiates TLS in a way OpenSSL 3 may reject.
          # Fallback to curl keeps compatibility in modern Ruby runtimes.
          raise unless e.message.to_s.downcase.include?('unsupported protocol')

          soap__request_with_curl(body)
        end

        return xml_response
      end

      def soap__request_with_net_http(body)
        uri           = URI.parse(request_url)
        request_engine              = Net::HTTP.new(uri.host, uri.port)
        request_engine.use_ssl      = true
        request_engine.verify_mode  = OpenSSL::SSL::VERIFY_NONE
        request_engine.open_timeout = 15.seconds
        request_engine.read_timeout = 15.seconds

        req                 = Net::HTTP::Post.new(uri.path)
        req['Content-Type'] = 'text/xml'
        req.body            = body

        res = request_engine.request(req)
        return res.body
      end

      def soap__request_with_curl(body)
        stdout, stderr, status = Open3.capture3(
          'curl',
          '--silent',
          '--show-error',
          '--insecure',
          '--header', 'Content-Type: text/xml',
          '--data-binary', '@-',
          request_url,
          stdin_data: body
        )

        raise StandardError, "curl SOAP request failed: #{stderr.strip}" unless status.success?

        return stdout
      end

      def soap__envelope(letter)
        envelope = <<~XML
          <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Body>
              #{letter}
            </soap:Body>
          </soap:Envelope>
        XML
        return envelope
      end

      def soap__letter_exchange_day(year, month, day)
        letter = <<-XML
          <RecuperaTC_Dia xmlns="http://servicios.bcn.gob.ni/">
            <Ano>#{year}</Ano>
            <Mes>#{month}</Mes>
            <Dia>#{day}</Dia>
          </RecuperaTC_Dia>
XML
        return letter
      end

      def soap__letter_exchange_month(year, month)
        letter = <<-XML
          <RecuperaTC_Mes xmlns="http://servicios.bcn.gob.ni/">
            <Ano>#{year}</Ano>
            <Mes>#{month}</Mes>
          </RecuperaTC_Mes>
XML
        return letter
      end

  end
end
