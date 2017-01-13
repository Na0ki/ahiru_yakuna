# -*- coding: utf-8 -*-

Plugin.create(:ahiru_yakuna) do

  criminals = Set.new
  あひる焼き = %w(あひる焼き Ahiruyaki 扒家鸭)

  def prepare
    begin
      @dictionary = Hash.new
      dictionaries = Dir.glob("#{File.join(__dir__, 'dictionary')}/*.yml")
      dictionaries.each { |d| @dictionary[File.basename(d, '.*')] = YAML.load_file(d) }
      @defined_time = Time.new.freeze
    rescue LoadError => e
      error e
      Service.primary.post(:message => '辞書の更新時にエラーが発生しました: %{time}' % {time: Time.now.to_s}, :replyto => Service.primary.user)
    end
  end

  def sample(key)
    @dictionary.values_at(key)[0].sample
  end


  def select_reply(msg, time)
    # お正月モード
    return sample('shogatsu') if Time.now.yday <= 3
    # 飯テロモード
    return sample('meshitero') if (time >= 17 and time <= 19) or (time >= 0 and time <= 3)

    # 言語ごとに使用辞書を変える
    return sample('english') if msg =~ /Ahiruyaki/
    return sample('chinese') if msg =~ /扒家鸭/
    sample('japanese')
  end


  # load reply dictionaries
  prepare


  filter_filter_stream_track do |watching|
    [(watching.split(','.freeze) + あひる焼き).join(',')]
  end


  on_appear do |ms|
    ms.each do |m|
      # メッセージ生成時刻が起動前またはリツイートならば次のループへ
      next if m[:created] < @defined_time or m.retweet?

      if m.to_s =~ Regexp.union(あひる焼き) and !criminals.include?(m.id)
        criminals << m.id
        # select reply dic & send reply & fav
        reply = select_reply(m.to_s, Time.now.hour)
        Service.primary.post(:message => '@%{id} %{reply}' % {id: m.user.idname, reply: reply}, :replyto => m)
        m.favorite(true)
      end

      if m.to_s =~ /辞書更新/ and m.user.idname == Service.primary.user
        prepare
        Service.primary.post(:message => '辞書の更新が完了しました: %{time}' % {time: Time.now.to_s}, :replyto => m)
      end

    end
  end

end
