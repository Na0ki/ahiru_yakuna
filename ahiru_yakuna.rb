# -*- coding: utf-8 -*-

Plugin.create(:ahiru_yakuna) do

  DEFINED_TIME = Time.new.freeze

  begin
    replyArray = YAML.load_file(File.join(File.dirname(__FILE__),"config.yml"))
  rescue LoadError
    notice "\"config.yml\" not found."
  end

  on_appear do |ms|
    dose_reply_self_message = UserConfig[:does_reply_self_message] || false

    ms.each do |m|
      if m.message.to_s =~ /あひる焼き/ and m[:created] > DEFINED_TIME and !m.retweet? and dose_reply_self_message
        replySentence = replyArray.sample
        Service.primary.post(:message => "#{"@" + m.user.idname + ' ' + replySentence}", :replyto => m)
        m.message.favorite(true)
      end
    end
  end

  settings 'ahiru_yakuna' do
    settings '「あひる焼き」への反応設定' do
      boolean('自分の発言に反応する（デバッグ用）', :does_reply_self_message)
    end
  end
end
