class User < ActiveRecord::Base
  has_many :remarks

  def self._add(access_token, name)
    # 参考: http://apiwiki.twitter.com/Twitter-API-Documentation
    access_token.post(
      'http://twitter.com/fendships/create.json',
      'screen_name' => name
    )
  end

  def self._create(access_token, name)
    begin
      if name =~ /@@(.+)@@/
        name.gsub!(/@@(.+)@@/) {$1}
      end

      user = User.find_by_name(name)
      if user
        user.delete_flag = 0
        user.save!
      else
        User.create!(:name => name)
        access_token.post(
          'http://twitter.com/statuses/update.json',
          'status' => "@#{name} フォローありがとうございます。一日一回くらいあなたの発言を適当にまとめるのでお楽しみに!!"
        )
      end
    rescue Twitter::RESTError => e
      p e.message
      sleep 60

      num = 0 if num.nil?
      num += 1
      exit if num >= 2

      retry
    rescue => e
      p e.message
      exit
    end
  end

  def self.remove_and_delete_flag(access_token, name, friends)
    begin
      access_token.post(
        'http://twitter.com/friendships/destroy.json',
        'screen_name' => name
      )
    rescue Twitter::RESTError => e
      p e.message
      sleep 60

      num = 0 if num.nil?
      num += 1
      exit if num >= 2

      retry
    rescue => e
      p e.message
      exit
    end

    delete_user = User.find(
      :first, 
      :conditions => ['name = ? AND delete_flag = 0', name]
    )
    if delete_user
      delete_user.delete_flag = 1
      delete_user.save!
    end
  end
end
