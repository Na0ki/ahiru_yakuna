 # -*- coding: utf-8 -*-
 
Plugin.create(:ahiru_yakuna) do
 
  DEFINED_TIME = Time.new.freeze
 
  begin
	replyArray = YAML.load_file(File.join(File.dirname(__FILE__),"config.yml"))
	meshiteroArray = YAML.load_file(File.join(File.dirname(__FILE__),"meshitero.yml"))
    steinArray = YAML.load_file(File.join(File.dirname(__FILE__),"stein.yml"))
    chineseArray = YAML.load_file(File.join(File.dirname(__FILE__),"chinese.yml"))
  rescue LoadError
   	notice "\"config.yml\" not found."
  end

  on_appear do |ms|
    ms.each do |m|
      if m.message.to_s =~ /あひる焼き|Ahiruyaki|扒家鸭/ and m[:created] > DEFINED_TIME and !m.retweet?
      	now = Time.now.hour
      	if (now >= 17 && now <= 19) || (now >= 0 && now <= 3) then
        	replySentence = meshiteroArray.sample
        else
          if m.message.to_s =~ /扒家鸭/
            replySentence = chineseArray.sample
          else
        	replySentence = replyArray.sample
          end
        end
        # if m.user.idname == "naota344"
        #   Service.primary.send_direct_message(text: replySentence,
                                            #   user: m.user.idname)
        # else
          Service.primary.post(:message => "#{"@" + m.user.idname + ' ' + replySentence}", :replyto => m)
          m.message.favorite(true)
        # end
      end
      if m.message.to_s =~ /ｳﾞｪﾝﾃﾞﾙｼｭﾀｲﾝ焼き/ and m[:created] > DEFINED_TIME and !m.retweet?
        replySentence = steinArray.sample
        if m.user.idname == "ahiru3net" || m.user.idname == "wendelstein__"
          Service.primary.post(:message => "#{"@" + "wendelstein__" + ' ' + replySentence}", :replyto => m)
        end
      end
    end
  end
end
