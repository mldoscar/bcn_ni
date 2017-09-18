require 'uri'
require 'net/http'
require 'net/https'
require 'json'

module BcnNi

  def self.exchange_day(year, month, day)
    # (see 'https://servicios.bcn.gob.ni/Tc_Servicio/ServicioTC.asmx')
    # for more info about how to build a SOAP RAW request)

    # Parse the URI
    uri = URI.parse('https://servicios.bcn.gob.ni/Tc_Servicio/ServicioTC.asmx?WSDL')
    
    # Create protocol to the URI
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    # Create a new POST request as XML content type
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' => 'text/xml'})

    # Set the request body as a RAW SOAP XML request
    req.body = <<EOF
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RecuperaTC_Dia xmlns="http://servicios.bcn.gob.ni/">
      <Ano>#{year}</Ano>
      <Mes>#{month}</Mes>
      <Dia>#{day}</Dia>
    </RecuperaTC_Dia>
  </soap:Body>
</soap:Envelope>
EOF
    # Process the request
    res = https.request(req)

    # Get the XML response
    xml_response = res.body

    # Parse to a JSON hash
    json_response = Hash.from_xml(xml_response)

    # Get the result value
    value_result = json_response['Envelope']['Body']['RecuperaTC_DiaResponse']['RecuperaTC_DiaResult']

    # Parse the result value and finally return it
    return value_result.to_f

  end

  def self.exchange_month(year, month)
    # (see 'https://servicios.bcn.gob.ni/Tc_Servicio/ServicioTC.asmx')
    # for more info about how to build a SOAP RAW request)

    # Parse the URI
    uri = URI.parse('https://servicios.bcn.gob.ni/Tc_Servicio/ServicioTC.asmx?WSDL')
    
    # Create protocol to the URI
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    # Create a new POST request as XML content type
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' => 'text/xml'})

    # Set the request body as a RAW SOAP XML request
    req.body = <<EOF
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RecuperaTC_Mes xmlns="http://servicios.bcn.gob.ni/">
      <Ano>#{year}</Ano>
      <Mes>#{month}</Mes>
    </RecuperaTC_Mes>
  </soap:Body>
</soap:Envelope>
EOF
    # Process the request
    res = https.request(req)

    # Get the XML response
    xml_response = res.body

    # Parse to a JSON hash
    json_response = Hash.from_xml(xml_response)

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
  
end
