# BcnNi
A pretty basic gem for consulting Nicaraguan money exchange reates using the BCN SOAP Service.

## Usage
```ruby
# Return the exchange rate for September 15th, 2017
rate = BcnNi.exchange_day(2017,9,15)
# 
# => 30.3537

# Return the exchange rate table for September, 2017
table = BcnNi.exchange_month(2017,9)
#
# => [
#    {:date=>Fri, 01 Sep 2017, :value=>30.2969},
#    {:date=>Sat, 02 Sep 2017, :value=>30.301},
#    {:date=>Sun, 03 Sep 2017, :value=>30.305},
#    {:date=>Mon, 04 Sep 2017, :value=>30.3091},
#    {:date=>Tue, 05 Sep 2017, :value=>30.3131},
#    {:date=>Wed, 06 Sep 2017, :value=>30.3172},
#    {:date=>Thu, 07 Sep 2017, :value=>30.3212},
#    {:date=>Fri, 08 Sep 2017, :value=>30.3253},
#    {:date=>Sat, 09 Sep 2017, :value=>30.3293},
#    {:date=>Sun, 10 Sep 2017, :value=>30.3334},
#    {:date=>Mon, 11 Sep 2017, :value=>30.3374},
#    {:date=>Tue, 12 Sep 2017, :value=>30.3415},
#    {:date=>Wed, 13 Sep 2017, :value=>30.3455},
#    {:date=>Thu, 14 Sep 2017, :value=>30.3496},
#    {:date=>Fri, 15 Sep 2017, :value=>30.3537},
#    {:date=>Sat, 16 Sep 2017, :value=>30.3577},
#    {:date=>Sun, 17 Sep 2017, :value=>30.3618},
#    {:date=>Mon, 18 Sep 2017, :value=>30.3658},
#    {:date=>Tue, 19 Sep 2017, :value=>30.3699},
#    {:date=>Wed, 20 Sep 2017, :value=>30.374},
#    {:date=>Thu, 21 Sep 2017, :value=>30.378},
#    {:date=>Fri, 22 Sep 2017, :value=>30.3821},
#    {:date=>Sat, 23 Sep 2017, :value=>30.3861},
#    {:date=>Sun, 24 Sep 2017, :value=>30.3902},
#    {:date=>Mon, 25 Sep 2017, :value=>30.3943},
#    {:date=>Tue, 26 Sep 2017, :value=>30.3983},
#    {:date=>Wed, 27 Sep 2017, :value=>30.4024},
#    {:date=>Thu, 28 Sep 2017, :value=>30.4065},
#    {:date=>Fri, 29 Sep 2017, :value=>30.4105},
#    {:date=>Sat, 30 Sep 2017, :value=>30.4146}
#  ]

```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'bcn_ni'
```

And then execute:
```bash
$ bundle
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
