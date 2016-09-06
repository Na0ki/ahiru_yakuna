# -*- coding: utf-8 -*-

Plugin.create(:ahiru_yakuna) do

  DEFINED_TIME = Time.new.freeze
  criminals = Set.new
  あひる焼き = %w(あひる焼き Ahiruyaki 扒家鸭)

  # load reply dictionaries
  begin
    JAPANESE = YAML.load_file(File.join(__dir__, 'replydic', 'default.yml'))
    MESHITERO = YAML.load_file(File.join(__dir__, 'replydic', 'meshitero.yml'))
    ENGLISH = YAML.load_file(File.join(__dir__, 'replydic', 'english.yml'))
    CHINESE = YAML.load_file(File.join(__dir__, 'replydic', 'chinese.yml'))
  rescue LoadError
    notice 'Could not load yml file'
  end

  filter_filter_stream_track do |watching|
    [(watching.split(','.freeze) + あひる焼き).join(',')]
  end


  def select_reply(msg, time)
    # 飯テロモード
    if (time >= 17 && time <= 19) || (time >= 0 && time <= 3)
      return MESHITERO.sample
    end

    # 言語ごとに使用辞書を変える
    if msg =~ /Ahiruyaki/
      return ENGLISH.sample
    elsif msg =~ /扒家鸭/
      return CHINESE.sample
    else
      return JAPANESE.sample
    end
  end


  on_appear do |ms|
    ms.each do |m|
      if m.to_s =~ Regexp.union(あひる焼き) and m[:created] > DEFINED_TIME and !m.retweet? and !criminals.include?(m.id)
        criminals << m.id
        now = Time.now.hour
        # select reply dic & send reply & fav
        reply = select_reply(m.to_s, now)
        Service.primary.post(:message => "@#{m.user.idname} #{reply}", :replyto => m)
        m.favorite(true)
      end
    end
  end

end
