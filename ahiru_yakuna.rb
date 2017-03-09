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
    @dictionary.values_at(key).first.sample
  end


  # 言語によって辞書を選ぶ
  # @param [String] msg リプライ先のツイート
  # @return [String] リプライメッセージ
  def language(msg)
    case msg
      when /Ahiruyaki/
        sample('english')
      when /扒家鸭/
        sample('chinese')
      else
        sample('japanese')
    end
  end


  # リプライを選ぶ
  # @param [String] msg リプライ先のツイート
  # @param [Time] time リプライを受けた時刻
  def select_reply(msg, time)
    hour = time.hour
    case
      when time.yday <= 3
        # お正月モード
        sample('shogatsu')
      when (17..19).include?(hour), (0..3).include?(hour)
        # 飯テロモード
        sample('meshitero')
      else
        language(msg)
    end
  end


  # 管理者のみ実行可能な機能
  # @param [Message] message メッセージインスタンス
  # @return [Delayer::Deferred::Deferrable]
  def admin_command(message)
    Thread.new(message) { |m|
      if m.to_s =~ /辞書更新/
        %x( cd #{File.join(__dir__, 'dictionary')} && git pull origin master )
        result = $?.success? ? '成功' : '失敗'
        notice "最新の辞書の取得に#{result}しました"
        prepare
        m.post(:message => "[あひる焼くな] 辞書の更新が完了しました\nリモートの辞書の取得に%{result}しました\n %{time}" % {time: Time.now.to_s, result: result},
               :replyto => m)
      end
    }
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
        m.post(:message => '@%{id} %{reply}' % {id: m.user.idname, reply: reply}, :replyto => m)
        m.favorite(true)
      end

      # ここから先は自分のみに反応する
      next if m.user[:id] != Service.primary.user_obj.id
      # 管理者コマンドの実行
      admin_command(m).trap { |e| error e }

    end
  end

end
