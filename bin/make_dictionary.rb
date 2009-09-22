#!/usr/bin/ruby

if ENV['RAILS_ENV'] = "production"
  DICPATH = '/var/www/matometter'
else
  DICPATH = '/home/sasata299/matometter'
end

CMD = "/usr/local/libexec/mecab/mecab-dict-index -d /usr/local/lib/mecab/dic/ipadic -u #{DICPATH}/config/matometter.dic -f utf-8 -t utf-8 #{DICPATH}/config/matometter.csv"

$:.push(File.expand_path(File.dirname(__FILE__)))
require 'base'

users =  Dictionary.find(:all).map { |dic| {:word => dic.word, :word_type => dic.word_type} }

File.open(File.expand_path(File.dirname(__FILE__)) + '/../config/matometter.csv', 'w') {|f|
  users.each do |user|
    katakana = NKF.nkf('-w --katakana', user[:word])
    f.puts "#{user[:word]},0,0,10,#{user[:word_type]},*,*,*,*,*,#{katakana},#{katakana},#{katakana}"
  end
}

system CMD
