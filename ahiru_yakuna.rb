# -*- coding: utf-8 -*-
# -*- frozen_string_literal: true -*-

Plugin.create(:ahiru_yakuna) do
  criminals = Set.new
  あひる焼き = %w[あひる焼き アヒルヤキ アヒル焼き Ahiruyaki 扒家鸭 3v.7g]

  # 辞書のロード
  # メソッド単位で rescue しているため begin ブロックは不要
  def prepare
    @dictionary = {}
    dictionaries = Dir.glob("#{File.join(__dir__, 'dictionary')}/*.yml")
    dictionaries.each { |d| @dictionary[File.basename(d, '.*')] = YAML.load_file(d) }
    @defined_time = Time.new.freeze
  rescue LoadError => e
    error e
    Service.primary.post(message: "[あひる焼くな] 辞書の更新時にエラーが発生しました: #{Time.now}",
                         replyto: Service.primary.user)
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
    when (17..19).cover?(hour), (0..3).cover?(hour)
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
        `cd #{File.join(__dir__, 'dictionary')} && git pull origin master`
        result = Process::Status.new.success? ? '成功' : '失敗'
        time = Time.now.to_s
        notice "最新の辞書の取得に#{result}しました: #{time}"
        prepare
        msg = <<~EOS
          [あひる焼くな] 辞書の更新が完了しました
          リモートの辞書の取得に#{result}しました
          #{time}
        EOS
        m.post(message: msg, replyto: m)
      end
    }
  end

  # load reply dictionaries
  prepare

  filter_filter_stream_track do |watching|
    [(watching.split(',') + あひる焼き).join(',')]
  end

  on_appear do |ms|
    ms.each do |m|
      # メッセージ生成時刻が起動前またはリツイートならば次のループへ
      next if m[:created] < @defined_time || m.retweet?

      if m.to_s =~ Regexp.union(あひる焼き) && !criminals.include?(m.id)
        criminals << m.id
        # select reply dic & send reply & fav
        reply = select_reply(m.to_s, Time.now)
        m.post(message: "@#{m.user.idname} #{reply}", replyto: m)
        m.favorite(true)
      end

      # ここから先は自分のみに反応する
      next if m.user[:id] != Service.primary.user_obj.id
      # 管理者コマンドの実行
      admin_command(m).trap { |e| error e }
    end
  end
end
