module Firetower
  module Rooms
    fattr(:subscribed_rooms) { [] }

    def join(subdomain, room_name)
      subscribed_rooms << find_room(subdomain, room_name)
    end
  end
end
