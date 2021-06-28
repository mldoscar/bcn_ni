# BcnNi

This gem provides NIO (Córdoba Oro Nicaragüense) against USD (United States Dollar) money exchange rates consuming the official Central Bank of Nicaragüa (BCN) SOAP Service or HTML page

## Basic usage

```ruby
# Returns the exchange rate for September 15th, 2017
day_rate = BcnNi.exchange_day(2017, 9, 15)
#
# => 30.3537

# Returns the exchange rate table for September, 2017
month_rate = BcnNi.exchange_month(2017, 9)
#
# => [
#     {:date=>Fri, 01 Sep 2017, :value=>30.2969},
#     {:date=>Sat, 02 Sep 2017, :value=>30.301},
#     {:date=>Sun, 03 Sep 2017, :value=>30.305},
#     {:date=>Mon, 04 Sep 2017, :value=>30.3091},
#     {:date=>Tue, 05 Sep 2017, :value=>30.3131},
#     {:date=>Wed, 06 Sep 2017, :value=>30.3172},
#     {:date=>Thu, 07 Sep 2017, :value=>30.3212},
#     {:date=>Fri, 08 Sep 2017, :value=>30.3253},
#     {:date=>Sat, 09 Sep 2017, :value=>30.3293},
#     {:date=>Sun, 10 Sep 2017, :value=>30.3334},
#     {:date=>Mon, 11 Sep 2017, :value=>30.3374},
#     {:date=>Tue, 12 Sep 2017, :value=>30.3415},
#     {:date=>Wed, 13 Sep 2017, :value=>30.3455},
#     {:date=>Thu, 14 Sep 2017, :value=>30.3496},
#     {:date=>Fri, 15 Sep 2017, :value=>30.3537},
#     {:date=>Sat, 16 Sep 2017, :value=>30.3577},
#     {:date=>Sun, 17 Sep 2017, :value=>30.3618},
#     {:date=>Mon, 18 Sep 2017, :value=>30.3658},
#     {:date=>Tue, 19 Sep 2017, :value=>30.3699},
#     {:date=>Wed, 20 Sep 2017, :value=>30.374},
#     {:date=>Thu, 21 Sep 2017, :value=>30.378},
#     {:date=>Fri, 22 Sep 2017, :value=>30.3821},
#     {:date=>Sat, 23 Sep 2017, :value=>30.3861},
#     {:date=>Sun, 24 Sep 2017, :value=>30.3902},
#     {:date=>Mon, 25 Sep 2017, :value=>30.3943},
#     {:date=>Tue, 26 Sep 2017, :value=>30.3983},
#     {:date=>Wed, 27 Sep 2017, :value=>30.4024},
#     {:date=>Thu, 28 Sep 2017, :value=>30.4065},
#     {:date=>Fri, 29 Sep 2017, :value=>30.4105},
#     {:date=>Sat, 30 Sep 2017, :value=>30.4146}
#    ]

```

## Changing the request mode

For changing the request mode simply add `request_mode` argument at the end of the method args. **The default request mode is scrapping** (which incredibly resulted to be faster than SOAP and with 24/7 availability). You can change this like the example given below:

```ruby
# Scrapping mode
day_rate    = BcnNi.exchange_day(2017, 9, 15, request_mode: :scrapping)
month_rate  = BcnNi.exchange_month(2017, 9, request_mode: :scrapping)
# SOAP request mode
day_rate    = BcnNi.exchange_day(2017, 9, 15, request_mode: :soap)
month_rate  = BcnNi.exchange_month(2017, 9, request_mode: :soap)
```

## Installation

Add this line to your application's Gemfile:

```ruby
# From git repository
gem 'bcn_ni', git: 'https://github.com/mldoscar/bcn_ni', branch: 'master'

# From ruby gems
gem 'bcn_ni', '>= 0.1.5'

# Using gem install
gem install bcn_ni
```

And then execute:

```bash
$ bundle
```

## Changelog

```
2021.06.28 - Bugfix: Cambio en el URI para el request de scrapping, el BCN cambió de parámetros y ubicación de URL
```

## Contributing

You guys are free to send your pull requests for contributing. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the Contributor Covenant code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
