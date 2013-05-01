$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "soc_imp/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "soc_imp"
  s.version     = SocImp::VERSION
  s.authors     = ["Alex Melman"]
  s.email       = ["amelman5@gmail.com"]
  s.homepage    = "https://github.com/stoicsquirrel"
  s.summary     = "Social Importer"
  s.description = "Imports assets from social media, including Twitter, Instagram, and Tumblr."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 3.2.13"
  s.add_dependency "faraday"
  s.add_dependency "fog"

  s.add_development_dependency "pg"
  s.add_development_dependency "rspec-rails", "~> 2.0"
  s.add_development_dependency "webmock", [">= 1.8.0", "< 1.10"]
  s.add_development_dependency "vcr"
  s.add_development_dependency "twitter", "~> 4.6"
  s.add_development_dependency "tumblr_client"
  s.add_development_dependency "instagram"
end
