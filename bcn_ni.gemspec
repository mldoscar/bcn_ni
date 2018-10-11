$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem"s version:
require "bcn_ni/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "bcn_ni"
  s.version     = BcnNi::VERSION
  s.authors     = ["Oscar Rodriguez"]
  s.email       = ["mld.oscar@yahoo.com"]
  s.homepage    = "https://github.com/mldoscar/bcn_ni"
  s.summary     = "This gem provides NIO (Córdoba oro Nicaragüense) versus USD (United States dollar) money exchange rates consuming the official Central Bank of Nicaragüa (BCN) SOAP Service"
  s.description = "This gem provides NIO (Córdoba oro Nicaragüense) versus USD (United States dollar) money exchange rates consuming the official Central Bank of Nicaragüa (BCN) SOAP Service"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "activesupport", "~> 5.1", ">= 5.1.3"
  s.add_dependency 'savon', '~> 2.12'

  s.add_development_dependency "rails", "~> 5.1", ">= 5.1.3"
  s.add_development_dependency "sqlite3", "~> 1.3", ">= 1.3.12"
end
