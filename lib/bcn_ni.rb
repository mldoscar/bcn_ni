require 'active_support/core_ext/hash'
require 'savon'

module BcnNi

  def self.exchange_day(year, month, day)
    # Build body through a XML envelope
    body = self.post_webservice(year, month, day)

    # Return exchange rate value
    body[:recupera_tc_dia_response][:recupera_tc_dia_result].to_f
  end

  def self.exchange_month(year, month)
    # Build body through a XML envelope
    body = self.post_webservice(year, month)

    # Get the result array
    exchange_rates = body[:recupera_tc_mes_response][:recupera_tc_mes_result][:detalle_tc][:tc]

    if exchange_rates.any?
      # Parse the table to a custom and better JSON
      # The format example will be: {date: as Date, value: as Float}
      parsed_table = exchange_rates.map { |e| { date: e[:fecha], value: e[:valor].to_f } }

      # Sort the parsed table and finally return it
      return parsed_table.sort_by { |e| e[:date] }
    else
      return []
    end

  end

  private

  def self.post_webservice(year, month, day = nil)
    date = { Ano: year, Mes: month }
    date[:Dia] = day if day.present?

    request = Savon.client do
      wsdl 'https://servicios.bcn.gob.ni/Tc_Servicio/ServicioTC.asmx?WSDL'
      convert_request_keys_to :camelcase
    end

    exchange_rates = day.nil? ? :recupera_tc_mes : :recupera_tc_dia

    request.call(exchange_rates, message: date).body
  end
end
