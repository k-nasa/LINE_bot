require 'sinatra'
require 'line/bot'

# 微小変更部分！確認用。
get '/' do
  "Hello world"
end

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["f16f4adbbc91fd4ab9f1e36027676ac3"]
    config.channel_token = ENV["bdrOqa+vmGEJch5K/cTyJGhqIXJn8Rs6Y4X42a93P9vvL78w76xS1r876jm88csWlZF6DR3LZsKPU6iBhKh5jCfXxSM+0w72x/uhHDe7RqpWOWykACGfDU9rvht2P4TzqXFDlRU2EHOzKm8v1heiyQdB04t89/1O/w1cDnyilFU="]
  }
end

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
      when Line::Bot::Event::MessageType::Text
        message = {
          type: 'text',
          text: event.message['text']
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
