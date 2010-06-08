require 'rubygems'
require 'oauth'
require 'yaml'
require 'active_record'

env = ENV['RAILS_ENV'] || 'development'

Dir.glob(File.expand_path(File.dirname(__FILE__)) + '/../app/models/*') {|filepath|
  require filepath
}
config = YAML.load_file(File.expand_path(File.dirname(__FILE__)) + '/../config/database.yml')
ActiveRecord::Base.establish_connection( config[env] )

class MyOAuth
  def self.get_access_token
    _oauth = YAML.load_file( File.expand_path(File.dirname(__FILE__)) + '/../config/oauth.yml' )
    
    consumer = OAuth::Consumer.new(
      _oauth['CONSUMER_KEY'],
      _oauth['CONSUMER_SECRET'],
      :site => 'http://twitter.com'
    )
    
    OAuth::AccessToken.new(
      consumer,
      _oauth['ACCESS_TOKEN'],
      _oauth['ACCESS_TOKEN_SECRET']
    )
  end
end

