module Firetower
  module Rooms
    def self.included(other)
      
    end
    fattr(:subscribed_rooms) { [] }

    def join_room(subdomain, room_name)
      subscribed_rooms << find_room(subdomain, room_name)
    end

    # Fix backwards compatability with 0.0.3
    alias_method :join, :join_room
  end
end
