# -*- coding: utf-8 -*-

Plugin.create(:ahiru_yakuna) do

  DEFINED_TIME = Time.new.freeze

  replyArray = ["焼くな", "おう、火力足んねぇぞ！", "延焼してどうぞ", "焼いちゃらめえええええええ", "焼いちゃうのか？！本当に焼いちゃうのか？！", "貴様はすでに延焼している"]
  on_appear do |ms|
    ms.each do |m|
      if m.message.to_s =~ /あひる焼き/ and m[:created] > DEFINED_TIME
        replySentence = replyArray.sample
        Service.primary.post(:message => "#{"@" + m.user.idname + ' ' + replySentence}", :replyto => m)
        m.message.favorite(true)
      end
    end
  end
end
