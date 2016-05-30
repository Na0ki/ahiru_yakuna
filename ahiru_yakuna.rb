# -*- coding: utf-8 -*-

Plugin.create(:ahiru_yakuna) do

  DEFINED_TIME = Time.new.freeze

  # load reply dictionaries
  begin
    config = YAML.load_file(File.join(__dir__, 'config.yml'))
    meshitero = YAML.load_file(File.join(__dir__, 'meshitero.yml'))
    stein = YAML.load_file(File.join(__dir__, 'stein.yml'))
    chinese = YAML.load_file(File.join(__dir__, 'chinese.yml'))
  rescue LoadError
    notice 'Could not load yml file'
  end

  on_appear do |ms|
    ms.each do |m|
      if m.message.to_s =~ /あひる焼き|Ahiruyaki|扒家鸭/ and m[:created] > DEFINED_TIME and !m.retweet?
        now = Time.now.hour
        # load meshitero dic if it's meshitero time
        if (now >= 17 && now <= 19) || (now >= 0 && now <= 3)
          reply = meshitero.sample
        else
          if m.message.to_s =~ /扒家鸭/
            reply = chinese.sample
          else
            reply = config.sample
          end
        end
        Service.primary.post(:message => "#{'@' + m.user.idname + ' ' + reply}", :replyto => m)
        m.message.favorite(true)
      end
      if m.message.to_s =~ /ｳﾞｪﾝﾃﾞﾙｼｭﾀｲﾝ焼き/ and m[:created] > DEFINED_TIME and !m.retweet?
        reply = stein.sample
        if m.user.idname == 'ahiru3net' || m.user.idname == 'wendelstein__'
          Service.primary.post(:message => "#{'@' + m.user.idname + ' ' + reply}", :replyto => m)
        end
      end
    end
  end

end
