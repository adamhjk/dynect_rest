$:.unshift(File.dirname(__FILE__) + '/lib')
require 'dynect_rest/version'

Gem::Specification.new do |s|
  s.name = "dynect_rest"
  s.version = DynectRest::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Adam Jacob", "Ranjib Dey"]
  s.date = "2013-08-23"
  s.description = "Use the Dynect services REST API"
  s.email = "adam@opscode.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.homepage = "http://github.com/adamhjk/dynect_rest"
  s.files = %w(Rakefile LICENSE ) + Dir.glob("{lib,spec}/**/*", File::FNM_DOTMATCH).reject {|f| File.directory?(f) }
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "Dynect REST API library"
  s.add_dependency "rest-client"
  s.add_dependency "json"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", ">= 2.10.0"
  s.add_development_dependency "yard"
end

