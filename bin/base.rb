env = ENV['RAILS_ENV'] || 'development'

require 'rubygems'
require 'active_record'
Dir.glob(File.expand_path(File.dirname(__FILE__)) + '/../app/models/*') {|filepath|
  require filepath
}
config = YAML.load_file(File.expand_path(File.dirname(__FILE__)) + '/../config/database.yml')
ActiveRecord::Base.establish_connection( config[env] )

