# -*- coding: utf-8 -*-

Plugin.create(:ahiru_yakuna) do

  DEFINED_TIME = Time.new.freeze

  # load reply dictionaries
  begin
    default = YAML.load_file(File.join(__dir__, 'replydi', 'default.yml'))
    meshitero = YAML.load_file(File.join(__dir__, 'replydic', 'meshitero.yml'))
    chinese = YAML.load_file(File.join(__dir__, 'replydic', 'chinese.yml'))
  rescue LoadError
    notice 'Could not load yml file'
  end

  on_appear do |ms|
    ms.each do |m|
      if m.message.to_s =~ /あひる焼き|Ahiruyaki|扒家鸭/ and m[:created] > DEFINED_TIME and !m.retweet?
        now = Time.now.hour
        # select reply dic & get sample reply
        if (now >= 17 && now <= 19) || (now >= 0 && now <= 3)
          reply = meshitero.sample
        else
          if m.message.to_s =~ /扒家鸭/
            reply = chinese.sample
          else
            reply = default.sample
          end
        end

        # send reply & fav
        Service.primary.post(:message => "@#{m.user.idname} #{reply}", :replyto => m)
        m.message.favorite(true)
      end
    end
  end

end
