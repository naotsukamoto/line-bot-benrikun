require 'sinatra'
# LINEのruby用api
require 'line/bot'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

get '/' do
  # 曜日割り振り
  d = Date.today
  if d.wday = 0
    message = {
      type: 'text',
      text: '今日は日曜日です。'
    }
  elsif d.wday = 6
    message = {
      type: 'text',
      text: '今日は土曜日です。'
    }
  end
  # task用

  response = client.push_message("Ue03fa0344cf6da7047fc11d233eb74b3", message)
  p response
end
# タスク用終了


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
