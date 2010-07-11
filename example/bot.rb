# Drop this in ~/.firetower/firetower.conf for a simple (and VERY UNSAFE!) demo
# of a Campfire bot:

receive do |session, event|
  if event['type'] == 'TextMessage' && event['body'] =~ /^!eval (.*)$/
    event.room.account.paste!(event.room.name, "Eval result:\n" + eval($1).to_s)
  end
end
