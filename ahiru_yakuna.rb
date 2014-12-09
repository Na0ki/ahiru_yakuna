 # -*- coding: utf-8 -*-
 
 Plugin.create(:ahiru_yakuna) do
 
   DEFINED_TIME = Time.new.freeze
 
   begin
     replyArray = YAML.load_file(File.join(File.dirname(__FILE__),"config.yml"))
   rescue LoadError
     notice "\"config.yml\" not found."
   end

   on_appear do |ms|
     ms.each do |m|
       if m.message.to_s =~ /あひる焼き/ and m[:created] > DEFINED_TIME and !m.retweet?
         replySentence = replyArray.sample
         Service.primary.post(:message => "#{"@" + m.user.idname + ' ' + replySentence}", :replyto => m)
         m.message.favorite(true)
       end
     end
   end
 end
