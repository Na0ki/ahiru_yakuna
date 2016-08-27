# -*- coding: utf-8 -*-

Plugin.create(:ahiru_yakuna) do

  DEFINED_TIME = Time.new.freeze
  criminals = Set.new
  あひる焼き = %w(あひる焼き Ahiruyaki 扒家鸭)

  # load reply dictionaries
  begin
    default = YAML.load_file(File.join(__dir__, 'replydic', 'default.yml'))
    meshitero = YAML.load_file(File.join(__dir__, 'replydic', 'meshitero.yml'))
    chinese = YAML.load_file(File.join(__dir__, 'replydic', 'chinese.yml'))
  rescue LoadError
    notice 'Could not load yml file'
  end

  filter_filter_stream_track do |watching|
    [(watching.split(','.freeze) + あひる焼き).join(",")]
  end

  on_appear do |ms|
    ms.each do |m|
      if m.to_s =~ Regexp.union(あひる焼き) and m[:created] > DEFINED_TIME and !m.retweet? and !criminals.include?(m.id)
        criminals << m.id
        now = Time.now.hour
        # select reply dic & get sample reply
        if (now >= 17 && now <= 19) || (now >= 0 && now <= 3)
          reply = meshitero.sample
        else
          if m.to_s =~ /扒家鸭/
            reply = chinese.sample
          else
            reply = default.sample
          end
        end

        # send reply & fav
        Service.primary.post(:message => "@#{m.user.idname} #{reply}", :replyto => m)
        m.favorite(true)
      end
    end
  end

end
