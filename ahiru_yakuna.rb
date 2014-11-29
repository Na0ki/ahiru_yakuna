# -*- coding: utf-8 -*-

Plugin.create(:ahiru_yakuna) do

  DEFINED_TIME = Time.new.freeze

  replyArray = ["あ、ミディアムレアでよろしく","我が輩を焼くなど897年早いわ！！！","不完全燃焼","Wer meines Speeres Spitze furchtet, durchschreite das feuer nie!","unlimited blaze works","「――――I am the bone of my roaring flames. 体は　　炎で　出来ている」","小便は済ませたか？神様にお祈りは？部屋の隅でガタガタ震えて燃焼する心の準備はOK？","邪王炎殺黒龍波","闇の炎に抱かれて燃えろ","あひる焼くな細胞は存在します","誰が誰にあひる焼きジデモ゛オンナジヤ、オンナジヤ思っでえ！ ウーハッフッハーン！！ ッウーン！","明日は我が身","バーニング・ダーク・フレイム・オブ・ディッセンバー","らこらこらこ～w","ｙａｋａｒｅｓｕｇｉ（ｋａｋｕｊｉｔｕｎｉ）","そんなにっ！焼いたらっ！ｱﾝｯ!ｱﾝｯ!ｱﾝｯ!ｱﾝｯ!","あ、これ焼かれてるんじゃないんで。ちょっとトランザムしてるだけなんで。","天照","焼きすぎ注意報","溶鉱炉に突っ込むね☆","あなたのプロジェクト、炎上しますよ？","焼かないで焼かないで震えといて","あふん","焼くでない", "おう、火力足んねぇぞ！", "延焼してどうぞ", "焼いちゃらめえええええええ", "焼いちゃうのか？！本当に焼いちゃうのか？！", "貴様はすでに延焼している"]
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
