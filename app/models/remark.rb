class Remark < ActiveRecord::Base
  belongs_to :user
  has_many :classifies

  $KCODE = 'u'

  require 'MeCab'
  require 'scrapi'
  require 'pp'
  require 'mechanize'

  def self.scrape_timeline(user_name, user_id)
    data = Scraper.define do
      process 'ol#timeline span.status-body > span.entry-content', 'remarks[]' => :text
      result :remarks
    end.scrape( URI.parse("http://twitter.com/#{user_name}"), :parser_options => {:char_encoding => 'utf8'} ) rescue nil

    data = scrape_by_mechanize(user_name) if data.nil?
    return nil if data.nil?

    return data.map {|d| 
      {
        :user_id => user_id,
        :remark  => d,
        :wakati  => self.wakatigaki(d).gsub(/\n/, '')
      } 
    }
  end

  def self.wakatigaki(remark)
    mecab = MeCab::Tagger.new('-O wakati')
    return mecab.parse( Utils.remove_noise(remark) )
  end

  def self.scrape_by_mechanize(user_name)
    begin
      agent = Utils.mechanize_login
    rescue WWW::Mechanize::ResponseCodeError => e
      p e.response_code
      sleep 60
      retry
    end
     
    all_entries = []
      
    begin
      page = agent.get("http://twitter.com/#{user_name}")
    rescue WWW::Mechanize::ResponseCodeError => e
      case e.response_code
      when '404'
        p e.response_code
        return nil
      else
        p e.response_code
        sleep 60
        retry
      end
    end
    entries = page/"div.section"/"span.entry-content"
    entries.each do |entry|
      all_entries << entry.inner_text
    end

    return all_entries
  end
end
