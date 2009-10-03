module Utils
  def self.remove_noise(remark)
    #remark.gsub!(/RT.+$/,'') if remark =~ /RT.+$/
    remark.gsub!(/RT /,'') if remark =~ /RT /
    remark.gsub!(/http:[^\s]+$/,'') if remark =~ /http:[^\s]+$/
    remark.gsub!(/@[^\s]+:? /,'') if remark =~ /@[^\s]+:? /
    remark.gsub!(/@[^\s]+:?$/,'') if remark =~ /@[^\s]+:?$/

    return remark
  end

  def mechanize_login
    config = YAML.load_file('/var/www/matometter/config/twitter.yml'
  )
    login = config['twitter']['login']
    password = config['twitter']['password']
  
    agent = WWW::Mechanize.new
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
    agent = mechanize_login
    
    user_followers_page = agent.get("http://twitter.com/followers")
    @followers_num = (user_followers_page/"span#follower_count").inner_text.to_i
  
    follower_page = nil
    page_id = nil
    now_follow = []
  
    loop do
      begin
        if page_id
          follower_page = agent.get("http://twitter.com/followers?page=#{page_id}")
        else
          follower_page = agent.get("http://twitter.com/followers")
        end
  
        followers = follower_page/"div#follow"/"span.'label screenname'"/"a"
        followers.each do |follow|
          next if follow.inner_text =~ /キャンセル/
          now_follow << follow.inner_text
        end
        if link_array = follower_page.links.select {|link| link.href =~ /page/}
          /\?page=(\d+)/ =~ link_array[0].href rescue break
          page_id = $1.to_i
        else
          break
        end
      rescue WWW::Mechanize::ResponseCodeError => e
        p 'Bad Gateway ?'
        sleep 60
        retry
      end
    end
    
    return now_follow
  end
  
  def get_self_friends
    agent = login
    
    follower_page = nil
    page_id = nil
    now_friend = []
  
    loop do
      begin
        if page_id
          follower_page = agent.get("http://twitter.com/following?page=#{page_id}")
        else
          follower_page = agent.get("http://twitter.com/following")
        end
  
        followers = follower_page/"div#follow"/"span.'label screenname'"/"a"
        followers.each do |follow|
          now_friend << follow.inner_text
        end
        if link_array = follower_page.links.select {|link| link.href =~ /page/}
          /\?page=(\d+)/ =~ link_array[0].href rescue break
          page_id = $1.to_i
        else
          break
        end
      rescue WWW::Mechanize::ResponseCodeError => e
        p 'Bad Gateway ?'
        sleep 60
        retry
      end
    end
    
    return now_friend
  end

  module_function :get_self_followers, :get_self_friends
end
