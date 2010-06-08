module Utils
  def self.remove_noise(remark)
    #remark.gsub!(/RT.+$/,'') if remark =~ /RT.+$/
    remark.gsub!(/RT /,'') if remark =~ /RT /
    remark.gsub!(/http:\/\/.+$/,'') if remark =~ /http:\/\//
    remark.gsub!(/#[^\s]+\s?/,'') if remark =~ /#[^\s]+\s?/
    remark.gsub!(/@[^\s]+:?\s?/,'') if remark =~ /@[^\s]+:?\s?/

    return remark
  end

  def self.mechanize_login
    config = YAML.load_file('/var/www/matometter/config/twitter.yml')
    login = config['twitter']['login']
    password = config['twitter']['password']
  
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac FireFox'
    page = agent.get('http://twitter.com/login')
    #login_form = page.forms.first
    login_form = page.forms[1]
    login_form['session[username_or_email]'] = login
    login_form['session[password]'] = password
    home_page = agent.submit(login_form)
    agent
  end

  def get_self_followers
    agent = Utils.mechanize_login
    
    user_followers_page = agent.get("http://twitter.com/followers")
    @followers_num = (user_followers_page/"span#follower_count").inner_text.gsub(/,/, '').to_i
  
    follower_page = nil
    page_id = nil
    now_follow = []
    error_num = 0

    loop do
      begin
        if page_id
          follower_page = agent.get("http://twitter.com/followers?page=#{page_id}")
        else
          follower_page = agent.get("http://twitter.com/followers")
        end
  
        followers = follower_page/"div#follow"/"span[@class='label screenname']"/"a"
        plus_info = follower_page/"div#follow"/"span.is-relationship"
        followers.each_with_index do |follow,i|
          if follow.to_s =~ /のツイートは非公開にしています/
            if plus_info[i].to_s =~ /(?:キャンセル|フォロー中)/
              user_name = follow.inner_text
            else
              user_name = "@@#{follow.inner_text}@@"
            end
          else
            user_name = follow.inner_text
          end
          now_follow << user_name
        end
        if next_link = follower_page.links.select {|link| link.href =~ /\?page=\d/}
          if next_link[0].nil?
            break
          elsif next_link[0].href =~ /\?page=(\d+)/
            page_id = $1.to_i
          end
        end
      rescue Mechanize::ResponseCodeError => e
        p e.message
        error_num += 1
        return [] if error_num > 2
        sleep 60
        retry
      end
    end
    
    return now_follow
  end
  
  def get_self_friends
    agent = Utils.mechanize_login
    
    follower_page = nil
    page_id = nil
    now_friend = []
    error_num = 0
  
    loop do
      begin
        if page_id
          follower_page = agent.get("http://twitter.com/following?page=#{page_id}")
        else
          follower_page = agent.get("http://twitter.com/following")
        end
  
        followers = follower_page/"div#follow"/"span[@class='label screenname']"/"a"
        followers.each do |follow|
          now_friend << follow.inner_text
        end
        if next_link = follower_page.links.select {|link| link.href =~ /\?page=\d/}
          if next_link[0].nil?
            break
          elsif next_link[0].href =~ /\?page=(\d+)/
            page_id = $1.to_i
          end
        end
      rescue Mechanize::ResponseCodeError => e
        p e.message
        error_num += 1
        return [] if error_num > 2
        sleep 60
        retry
      end
    end
    
    return now_friend
  end

  module_function :get_self_followers, :get_self_friends
end
