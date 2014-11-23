# -*- coding: utf-8 -*-

Plugin.create(:ahiru_yakuna) do
  on_appear do |ms|
    ms.each do |m|
      if m.message.to_s =~ /あひる焼き/
        Service.primary.post(:message => "#{"@" + m.user.idname} 焼くな", :replyto => m)
        m.message.favorite(true)
      end
    end
  end
end
