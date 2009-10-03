class Generater < ActiveRecord::Base
  def self.generate_sentence(user_id)
    ids = Remark.find(
      :all, 
      :select     => 'id',
      :conditions => [ 'user_id = ?', user_id ],
      :order      => 'updated_at DESC',
      :limit      => 20
    ).map { |remark| remark.id }
    return nil if ids.empty?

    @classifies = Classify.find(
      :all, 
      :conditions => "word <> '' and LENGTH(word) > 1 and remark_id IN (#{ids.join(',')})"
    )
    if @classifies.empty?
      File.open('/var/www/matometter/no_classifies', 'w') {|f|
        f.puts user_id
        f.puts ids.join(',')
      }
      File.open('/var/www/matometter/now_id', 'w') {|f|
        f.puts user_id
      }
      exit
    end

    @classifies_last = Classify.find(
      :all, 
      :conditions => %Q/word <> '' and word LIKE '%。' AND remark_id IN (#{ids.join(',')})/
    )

    return random_repeat(4 + rand(4))
  end

  private
  
  def self.random_repeat(num = 4)
    array = []

    (num - 1).times do
      array << @classifies[ rand(@classifies.size) ].word
    end
    last = @classifies_last.empty? ? '' : @classifies_last[ rand(@classifies_last.size) ].word
    array << last

    return array.join('')
  end
end
