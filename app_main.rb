require 'sinatra'
require 'line/bot'
require 'httpclient'
require 'json'
#動作 確認用。
get '/' do
  "Hello world"
end

#botのtoken,secretの登録
def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

#botの中身
post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      
      #テキストがbotに送信された場合message[text]が送信される
      when Line::Bot::Event::MessageType::Text
        if event.message['text'] =="こんにちは"
          reply = chat(event.message['text'])
        else
          reply = event.message['text']
        end

        #返信メッセージ
        message = {
          type: 'text',
          text: reply
        }
        client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end
    end
  }

  "OK"
end

def weather
  "今日の天気は晴れ！"
end

#雑談APIと会話
def chat(msg)
  puts 'Me>' + msg
  body = JSON.generate(utt: msg) # {:utt => msg}のこと
  clnt = HTTPClient.new
  uri = 'https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=3549664a4c676144774c50573564565265784865326964767739705a714a304c307630586b683948354839'
  res = clnt.post_content(uri, body, {'Content-Type' => 'application/json'})
  my_hash = JSON.parse(res)
  return  my_hash['utt'].to_s
end
