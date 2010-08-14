module Firetower
  module Plugins
    class GrowlPlugin < Firetower::Session::Listener
      def startup(session)
        if session.kind == :server
          notify("Firetower", "Firetower is vigilantly scanning the treetops")
        end
      end

      def join(session, room)
        notify("Firetower", "Joined room \"#{room.name}\"", room.name)
      end

      def leave(session, room)
        notify("Firetower", "Left room \"#{room.name}\"", room.name)
      end

      def receive(session, event)
        case event['type']
        when "TextMessage"
          user = event.room.account.users[event['user_id']]
          notify(user['name'], event['body'], event.room.name)
        else
          # NOOP
        end
      end

      def error(session, error)
        notify("Campfire Error", error.message, 'Error')
      end

      private

      def notify(*args)
        system('growlnotify', '-t', (args[2].nil? ? args[0] : "#{args[0]} - #{args[2]}"), 
          '-m', args[1], 
          '--image', File.expand_path('campfire-logo-for-fluid.png', File.dirname(__FILE__))) \
            or raise "Growl notification failed"
      end
    end
  end
end
