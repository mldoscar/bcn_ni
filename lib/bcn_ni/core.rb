module BcnNi
  require File.expand_path(File.dirname(__FILE__)) + '/helpers/request'

  def self.exchange_month(year, month, args = {})
    request = BcnNi::Request.new(args)

    return request.exchange_month(year, month)
  end

  def self.exchange_day(year, month, day, args = {})
    request = BcnNi::Request.new(args)

    return request.exchange_day(year, month, day)
  end
end