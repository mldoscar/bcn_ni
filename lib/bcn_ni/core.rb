module BcnNi
  require File.expand_path(File.dirname(__FILE__)) + '/helpers/request'

  @@exceptions  = []

  def self.exchange_month(year, month, args = {})
    engine        = BcnNi::Request.new(args)

    result        = engine.exchange_month(year, month)
    @@exceptions  = engine.exceptions

    return result
  end

  def self.exchange_day(year, month, day, args = {})
    engine        = BcnNi::Request.new(args)

    result        = engine.exchange_day(year, month, day)
    @@exceptions  = engine.exceptions

    return result
  end

  def self.exceptions
    return @@exceptions
  end
end