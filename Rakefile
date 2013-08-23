require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "dynect_rest"
    gem.summary = %Q{Dynect REST API library}
    gem.description = %Q{Use the Dynect services REST API}
    gem.email = "adam@opscode.com"
    gem.homepage = "http://github.com/adamhjk/dynect_rest"
    gem.authors = ["Adam Jacob", "Ranjib Dey"]
    gem.add_development_dependency "rspec", ">= 2.10"
    gem.add_development_dependency "yard", ">= 0"
    gem.add_dependency('json')
    gem.add_dependency('rest-client')
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
