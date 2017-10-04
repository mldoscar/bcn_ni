require 'uri'
require 'net/http'
require 'net/https'
require 'active_support/core_ext/hash'
require 'json'

module BcnNi

  def self.exchange_day(year, month, day)
    # Build body through a XML envelope
    body = self.bcn_envelope(self.exchange_day_letter(year, month, day))

    json_response = self.do_request(body)

    # Get the result value
    value_result = json_response['Envelope']['Body']['RecuperaTC_DiaResponse']['RecuperaTC_DiaResult']

    # Parse the result value and finally return it
    return value_result.to_f

  end

  def self.exchange_month(year, month)
    # Build body through a XML envelope
    body = self.bcn_envelope(self.exchange_month_letter(year, month))

    json_response = self.do_request(body)

    # Get the result array
    exchange_table = json_response['Envelope']['Body']['RecuperaTC_MesResponse']['RecuperaTC_MesResult']['Detalle_TC']['Tc']

    unless exchange_table.nil?
      # Parse the table to a custom and better JSON
      # The format example will be: {date: as Date, value: as Float}
      parsed_table = exchange_table.map{|x| {date: Date.parse(x['Fecha']), value: x['Valor'].to_f} }

      # Sort the parsed table and finally return it
      return parsed_table.sort_by {|x| x[:date]}
    else
      return []
    end

  end

  private
    def self.do_request(body)
      # see 'https://servicios.bcn.gob.ni/Tc_Servicio/ServicioTC.asmx'
      # for more info about how to build a RAW SOAP request

      # Parse the URI
      uri = URI.parse('https://servicios.bcn.gob.ni/Tc_Servicio/ServicioTC.asmx?WSDL')

      # Create protocol to the URI
      https = Net::HTTP.new(uri.host, uri.port)

      https.use_ssl = true

      # Create a new POST request as XML content type
      req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' => 'text/xml'})

      # Set the request body as a RAW SOAP XML request
      req.body = body

      # Process the request
      res = https.request(req)

      # Get the XML response
      xml_response = res.body

      # Parse to a JSON hash
      return Hash.from_xml(xml_response)
    end

    def self.bcn_envelope(letter)
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

    def self.exchange_day_letter(year, month, day)
      letter = <<EOF
<RecuperaTC_Dia xmlns="http://servicios.bcn.gob.ni/">
  <Ano>#{year}</Ano>
  <Mes>#{month}</Mes>
  <Dia>#{day}</Dia>
</RecuperaTC_Dia>
EOF
      return letter
    end

    def self.exchange_month_letter(year, month)
      letter = <<EOF
<RecuperaTC_Mes xmlns="http://servicios.bcn.gob.ni/">
  <Ano>#{year}</Ano>
  <Mes>#{month}</Mes>
</RecuperaTC_Mes>
EOF
      return letter
    end

end
