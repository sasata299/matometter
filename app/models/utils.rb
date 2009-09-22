module Utils
  def self.remove_noise(remark)
    #remark.gsub!(/RT.+$/,'') if remark =~ /RT.+$/
    remark.gsub!(/RT /,'') if remark =~ /RT /
    remark.gsub!(/http:[^\s]+$/,'') if remark =~ /http:[^\s]+$/
    remark.gsub!(/@[^\s]+:? /,'') if remark =~ /@[^\s]+:? /

    return remark
  end
end
