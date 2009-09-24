class Remark < ActiveRecord::Base
  belongs_to :user
  has_many :classifies

  $KCODE = 'u'

  require 'MeCab'
  require 'scrapi'
  require 'pp'

  def self.scrape_timeline(user_name)
    data = Scraper.define do
      process 'ol#timeline span.status-body > span.entry-content', 'remarks[]' => :text
      result :remarks
    end.scrape( URI.parse("http://twitter.com/#{user_name}"), :parser_options => {:char_encoding => 'utf8'} ) rescue nil

    return nil if data.nil?
    return data.map {|d| 
      {
        :user_id => User.find_by_name(user_name).id,
        :remark  => d,
        :wakati  => self.wakatigaki(d).gsub(/\n/, '')
      } 
    }
  end

  def self.wakatigaki(remark)
    mecab = MeCab::Tagger.new('-O wakati')
    return mecab.parse( Utils.remove_noise(remark) )
  end
end
