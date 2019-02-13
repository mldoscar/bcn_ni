require 'spec_helper'

RSpec.describe 'BcnNi', type: :feature do

  it 'Shound return the correct exchange rate of a determinated day' do
    # Fetch the exchange rate for September 15th, 2017
    exchange_rate = BcnNi.exchange_day(2017, 9, 15)

    expected_rate = 30.3537

    expect(exchange_rate).to eq expected_rate
  end

  it 'Shound return the correct exchange rate table for a determinated month' do
    # Fetch the exchange rate table for September, 2017
    exchange_table = BcnNi.exchange_month(2017, 9)

    expected_table = [
      {:date=> Date.parse('2017-09-01'), :value=>30.2969},
      {:date=> Date.parse('2017-09-02'), :value=>30.301},
      {:date=> Date.parse('2017-09-03'), :value=>30.305},
      {:date=> Date.parse('2017-09-04'), :value=>30.3091},
      {:date=> Date.parse('2017-09-05'), :value=>30.3131},
      {:date=> Date.parse('2017-09-06'), :value=>30.3172},
      {:date=> Date.parse('2017-09-07'), :value=>30.3212},
      {:date=> Date.parse('2017-09-08'), :value=>30.3253},
      {:date=> Date.parse('2017-09-09'), :value=>30.3293},
      {:date=> Date.parse('2017-09-10'), :value=>30.3334},
      {:date=> Date.parse('2017-09-11'), :value=>30.3374},
      {:date=> Date.parse('2017-09-12'), :value=>30.3415},
      {:date=> Date.parse('2017-09-13'), :value=>30.3455},
      {:date=> Date.parse('2017-09-14'), :value=>30.3496},
      {:date=> Date.parse('2017-09-15'), :value=>30.3537},
      {:date=> Date.parse('2017-09-16'), :value=>30.3577},
      {:date=> Date.parse('2017-09-17'), :value=>30.3618},
      {:date=> Date.parse('2017-09-18'), :value=>30.3658},
      {:date=> Date.parse('2017-09-19'), :value=>30.3699},
      {:date=> Date.parse('2017-09-20'), :value=>30.374},
      {:date=> Date.parse('2017-09-21'), :value=>30.378},
      {:date=> Date.parse('2017-09-22'), :value=>30.3821},
      {:date=> Date.parse('2017-09-23'), :value=>30.3861},
      {:date=> Date.parse('2017-09-24'), :value=>30.3902},
      {:date=> Date.parse('2017-09-25'), :value=>30.3943},
      {:date=> Date.parse('2017-09-26'), :value=>30.3983},
      {:date=> Date.parse('2017-09-27'), :value=>30.4024},
      {:date=> Date.parse('2017-09-28'), :value=>30.4065},
      {:date=> Date.parse('2017-09-29'), :value=>30.4105},
      {:date=> Date.parse('2017-09-30'), :value=>30.4146}
    ]

    expect(exchange_table).to eq expected_table
  end
end