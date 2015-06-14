 # -*- coding: utf-8 -*-
 
Plugin.create(:ahiru_yakuna) do
 
  DEFINED_TIME = Time.new.freeze
  now = Time.now
  
  begin
 	 replyArray = YAML.load_file(File.join(File.dirname(__FILE__),"config.yml"))
 	 meshiteroArray = YAML.load_file(File.join(File.dirname(__FILE__),"meshitero.yml"))
  rescue LoadError
   notice "\"config.yml\" not found."
  end
 
  on_appear do |ms|
   ms.each do |m|
   if m.message.to_s =~ /あひる焼き|ahiruyaki/ and m[:created] > DEFINED_TIME and !m.retweet?
    if (now.hour < 19 && now.hour > 17) || (now.hour > 0 && now.hour < 3) then
     replySentence = meshiteroArray.sample
    else
    　replySentence = replyArray.sample
    end
    Service.primary.post(:message => "#{"@" + m.user.idname + ' ' + replySentence}", :replyto => m)
    m.message.favorite(true)
   end
  end
 end
end
