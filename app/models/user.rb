class User < ActiveRecord::Base
  has_many :remarks

  def self.add_and_create(client, name)
    begin
      if name =~ /@@(.+)@@/
        name.gsub!(/@@(.+)@@/) {$1}
#        client.friend(:add, name)
      end

      user = User.find_by_name(name)
      if user
        user.delete_flag = 0
        user.save!
      else
        User.create!(:name => name)
        client.status(:post, "@#{name} フォローありがとうございます。一日一回くらいあなたの発言を適当にまとめるのでお楽しみに!!")
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

  def self.remove_and_delete_flag(client, name, friends)
    begin
      client.friend(:remove, name) if friends.include?(name)
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
