require 'pathname'
require 'rubygems'
require 'test/unit'

DIR = Pathname.new(File.dirname(__FILE__))

if ENV['RAILS'].nil?
  require (DIR + '../../../../config/environment.rb').expand_path
  require 'active_support'
  require 'active_support/test_case'
  require 'active_record'
  require 'active_record/fixtures'
else
  gem 'activerecord', "=#{ENV['RAILS']}"
  gem 'activesupport', "=#{ENV['RAILS']}"
  require 'active_support'
  require 'active_support/test_case'
  require 'active_record'
  require 'active_record/fixtures'
  $LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
  Dir["#{$LOAD_PATH.last}/**/*.rb"].each do |path|
    require path[$LOAD_PATH.last.size + 1..-1]
  end
  require DIR + '..' + 'init.rb'
end

config = YAML::load(IO.read(DIR + 'database.yml'))
ActiveRecord::Base.configurations.update config
ActiveRecord::Base.logger = Logger.new(DIR + "debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3_memory'])

load(DIR + "schema.rb")

class ActiveSupport::TestCase #:nodoc:
  include ActiveRecord::TestFixtures
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = false
  self.fixture_path = DIR + "fixtures"
end
