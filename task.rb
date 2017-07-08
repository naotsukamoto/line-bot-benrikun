get '/push' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  message_1 = {
    type: 'text',
    text: 'aaa'
  }
  client.reply_message(event['replyToken'], message_1)

  puts "done"
end
