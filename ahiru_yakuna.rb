# -*- coding: utf-8 -*-

Plugin.create(:ahiru_yakuna) do

  criminals = Set.new
  あひる焼き = %w(あひる焼き Ahiruyaki 扒家鸭)

  # 辞書のロード
  def prepare
    begin
      @dictionary = Hash.new
      dictionaries = Dir.glob("#{File.join(__dir__, 'dictionary')}/*.yml")
      dictionaries.each { |d| @dictionary[File.basename(d, '.*')] = YAML.load_file(d) }
      @defined_time = Time.new.freeze
    rescue LoadError => e
      error e
      Service.primary.post(:message => '[あひる焼くな] 辞書の更新時にエラーが発生しました: %{time}' % {time: Time.now.to_s}, :replyto => Service.primary.user)
    end
  end


  # 対応するファイルの辞書から一つサンプルを取り出す
  # @param [String] key 辞書の名前
  # @return [String] リプライ文字列
  def sample(key)
    @dictionary.values_at(key)[0].sample
  end


  # リプライを選ぶ
  # @param [String] msg リプライ先のツイート
  # @param [Time] time リプライを受けた時刻（hourのみ）
  def select_reply(msg, time)
    # お正月モード
    return sample('shogatsu') if time.yday <= 3
    # 飯テロモード
    hour = time.hour
    return sample('meshitero') if ((hour >= 17 and hour <= 19) or (hour >= 0 and hour <= 3))

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
        reply = select_reply(m.to_s, Time.now)
        Service.primary.post(:message => '@%{id} %{reply}' % {id: m.user.idname, reply: reply}, :replyto => m)
        m.favorite(true)
      end

      if m.to_s =~ /辞書更新/ and m.user[:id] == Service.primary.user_obj.id
        prepare
        Service.primary.post(:message => '[あひる焼くな] 辞書の更新が完了しました: %{time}' % {time: Time.now.to_s}, :replyto => m)
      end

    end
  end

end
