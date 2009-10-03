class User < ActiveRecord::Base
  has_many :remarks

  def self.add_and_create(name)
    unless User.find_by_name(name)
      begin
        client.status(:post, "@#{name} フォローありがとうございます。一日一回くらいあなたの発言を適当にまとめるのでお楽しみに!!")
      rescue Twitter::RESTError => e
        p e.message
        sleep 60

        num = 0 if num.nil?
        num += 1
        exit if num >= 3

        retry
      rescue => e
        exit
      end
    end

    client.friend(:add, name)
    User.create!(:name => name)
  end

  def self.remove_and_delete_flag(name)
    begin
      client.friend(:remove, name) if friends.include?(name)
    rescue Twitter::RESTError => e
      p e.message
      sleep 60

      num = 0 if num.nil?
      num += 1
      exit if num >= 3

      retry
    rescue => e
      exit
    end
    delete_user = User.find(
      :first, 
      :conditions => ['name = ? AND delete_flag = 0', name]
    )
    delete_user.delete_flag = 1
    delete_user.save!
  end
end
