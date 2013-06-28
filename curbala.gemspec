Gem::Specification.new do |s|
  s.name        = "curbala"
  s.version     = "0.0.2"
  s.author      = "Frederick Fix"
  s.email       = "rickfix80004@gmail.com"
  s.homepage    = "http://github.com/rickfix/curbala"
  s.summary     = "Curb client wrapper which encourages DRY implementations of, and provides logging for, external REST/API/Service calls."
  s.description = "Does you application invoke services that have different URLs in different Rails environments?  Would you like to log the application input to each service call, have fine grain control over API-specific data encoding and decoding, and log responses for each service call?  Are some of your service calls exhibiting a 'long line' code odor?  Do your API developers test their calls using curl commands?  This little ditty remedied these symptoms in our system and, most imporantly, expedited our rails app development and troubleshooting with internal and external API teams."

  s.files        = Dir["{lib,spec}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.add_development_dependency 'rspec', '~> 2.10.0'
  s.add_development_dependency 'rails', '~> 3.2'
  s.add_development_dependency 'curb', '~> 0.8.1'

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end
