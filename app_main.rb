require 'sinatra'
require 'line/bot'

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
          reply = "黙れ"
        else
          reply = event.message['text']
        end
        message = {
          type: 'text',
          #text: weather
          #オウム返し
          #text: event.message['text']
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
