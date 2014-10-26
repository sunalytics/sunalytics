$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sunalytics/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sunalytics"
  s.version     = Sunalytics::VERSION
  s.authors     = ["Sunalytics"]
  s.email       = ["support@sunalytics.co"]
  s.homepage    = "http://sunalytics.co"
  s.summary     = "Sunalytics - Simple analytics for Ruby on Rails"
  s.description = "Little configration, no development effort. Anyone can do analytics with real-time data directly from your database."

  s.files = Dir["{app,config,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", '> 3.0'

end
