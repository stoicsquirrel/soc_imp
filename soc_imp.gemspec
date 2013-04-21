$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "soc_imp/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "soc_imp"
  s.version     = SocImp::VERSION
  s.authors     = ["Alex Melman"]
  s.email       = ["amelman5@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "Social Importer"
  s.description = "Imports assets from social media, including Twitter, Instagram, and Tumblr."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2.13"
  s.add_dependency "faraday"
  s.add_dependency "twitter", "~> 4.6"

  s.add_development_dependency "pg"
  s.add_development_dependency "rspec-rails", "~> 2.0"
end
