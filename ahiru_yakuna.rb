# -*- coding: utf-8 -*-

Plugin.create(:ahiru_yakuna) do

  criminals = Set.new
  あひる焼き = %w(あひる焼き Ahiruyaki 扒家鸭)

  def prepare
    begin
      @dictionary = Hash.new
      dictionaries = Dir.glob("#{File.join(__dir__, 'dictionary')}/*")
      dictionaries.each { |d| @dictionary[File.basename(d, '.*')] = YAML.load_file(d) }
      @defined_time = Time.new.freeze
    rescue LoadError => e
      error "An Error Occurred: #{e}"
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
      if m.to_s =~ Regexp.union(あひる焼き) and m[:created] > @defined_time and !m.retweet? and !criminals.include?(m.id)
        criminals << m.id
        # select reply dic & send reply & fav
        reply = select_reply(m.to_s, Time.now.hour)
        Service.primary.post(:message => "@#{m.user.idname} #{reply}", :replyto => m)
        m.favorite(true)
      elsif m.to_s =~ /辞書更新/ and m[:created] > @defined_time and m.user.idname == 'ahiru3net'
        Thread.new {
          prepare
        }.next { |_|
          Service.primary.post(:message => "@ahiru3net 辞書の更新が完了しました: #{Time.now.to_s}")
        }.trap { |err|
          error err
          Service.primary.post(:message => "@ahiru3net 辞書の更新時にエラーが発生しました: #{Time.now.to_s}")
        }
      end
    end
  end

end
