module Firetower
  class Account
    attr_reader :subdomain, :token, :session, :users

    def initialize(subdomain, token, session, options = {})
      @subdomain = subdomain
      @token     = token
      @session   = session
      @ssl       = options.fetch(:ssl) { false }
      @users = Hash.new do |cache, user_id|
        data = session.get(subdomain, "/users/#{user_id}.json")
        cache[user_id] = data['user']
      end
    end

    def rooms
      return @rooms if defined?(@rooms)
      @rooms = Hash.new do |h, k|
        raise "No room named #{k} in #{subdomain}"
      end
      data = session.get(subdomain, "/rooms.json")
      data['rooms'].each do |room_data|
        room = Room.new(self, room_data)
        @rooms[room.name] = room
      end
      @rooms
    end

    def say!(room_name, text)
      room_id = rooms[room_name].id
      session.post(subdomain, "/room/#{room_id}/speak.json", {
        'message' => {
          'body' => text
        }
      })
    end

    def paste!(room_name, text)
      room_id = rooms[room_name].id
      session.post(subdomain, "/room/#{room_id}/speak.json", {
        'message' => {
          'body' => text,
          'type' => 'PasteMessage'
        }
      })
    end

    def ssl?
      @ssl
    end
  end
end
