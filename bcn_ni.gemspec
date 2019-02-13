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
  s.description = "This tool pretends to be helpful for developers who can request exchange rates in a easier way"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "CODE_OF_CONDUCT.md"]

  s.add_dependency "activesupport", "~> 5.1", ">= 5.1.3"
  s.add_dependency "nokogiri",      "~> 1.10"

  s.add_development_dependency "rake",  "~> 12.3"
  s.add_development_dependency "rspec", "~> 3.8"
end
