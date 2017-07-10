require 'sinatra'
# LINEのruby用api
require 'line/bot'
# 日時取得
require 'date'

# 環境を明示する
set :environment, :production

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

# get '/test' do
#   p "hello world"
# end

get '/' do

  # 曜日割り振り
  d = DateTime.now
  if d.wday == 0 # 日曜の夜
    message = {
      type: 'text',
      text: '明日からお仕事です。目覚まし掛けましたか？'
    }
  elsif d.wday == 1 || d.wday == 4 # 月・木曜の夜
    case d.hour
    when 14
      message = {
        type: 'text',
        text: '明日は燃えるゴミの日です'
      }
    when 23
      message = {
        type: 'text',
        text: '今日は燃えるゴミの日です。忘れず出しましょう。'
      }
    end
  elsif d.wday == 3 # 水曜の夜
    case d.hour
    when 14
      message = {
        type: 'text',
        text: '明日は資源ゴミの日です'
      }
    when 23
      message = {
        type: 'text',
        text: '今日は資源ゴミの日です。忘れず出しましょう。'
      }
    end
  elsif d.wday == 5 # 金曜の夜
    case d.hour
    when 14
      message = {
        type: 'text',
        text: '明日は不燃ゴミの日です'
      }
    when 23
      message = {
        type: 'text',
        text: '今日は不燃ゴミの日です。忘れず出しましょう。'
      }
    end
  end
  # 自分に送る
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
