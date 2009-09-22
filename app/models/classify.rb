class Classify < ActiveRecord::Base
  belongs_to :remark

  $KCODE = 'u'
  require 'MeCab'

  def self.parse(remark)
    #mecab = MeCab::Tagger.new('-O wakati')
    #wakati_array = mecab.parse( Utils.remove_noise(remark) ).split(/ /)

    block = []
    finish_flag = 0
    force_flag = 0
    body = ''
    mecab = MeCab::Tagger.new()
    wakati_array = mecab.parse( Utils.remove_noise(remark) ).split(/\n/)

    wakati_array.each do |wa|
      word,type = wa.split(/\t/)
      next if word == 'EOS'
      next if word == '。'
      next if word =~ /^[『』「」【】（）()]$/
      word += ' ' if word =~ /(w|ｗ|なう|!)$/u
      word = '（笑）' if word == '笑'

      if force_flag == 1
        body += word
        force_flag = 0
        next
      end

      # 強制的に区切りにする
      if type =~ /^(助詞|記号|助動詞|読点)/
        finish_flag = 1
        body += word
      elsif type =~ /^(名詞|動詞|形容詞)/
        if finish_flag == 1
          block << body
          body = ''
          finish_flag = 0
        end
        body += word
      elsif type =~ /^接頭詞/
        block << body
        body = ''
        force_flag = 1
        finish_flag = 0
        body += word
      elsif type =~ /^副詞/
        body += word
        block << body
        body = ''
        finish_flag = 0
      end
    end
    block << body.gsub(/EOS/, '') unless body == 'EOS'

    block.each do |bb|
      bb << '。' if bb =~ /(す|た|い|る|う)$/
    end

    return block.select { |blo| blo.length >= 1 }
  end
end
