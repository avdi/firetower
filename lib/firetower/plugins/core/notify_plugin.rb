module Firetower
  module Plugins
    class NotifyPlugin < Firetower::Session::Listener

      def startup(session)
        if session.kind == :server
          notify("Firetower", "Firetower is vigilantly scanning the treetops")
        end
      end

      def join(session, room)
        notify("Firetower", "Joined room \"#{room.name}\"")
      end

      def leave(session, room)
        notify("Firetower", "Left room \"#{room.name}\"")
      end

      def receive(session, event)
        case event['type']
        when "TextMessage"
          user = event.room.account.users[event['user_id']]
          notify(user['name'], event['body'])
        else
          # NOOP
        end
      end

      def error(session, error)
        notify("Campfire Error", error.message)
      end

      private

      def notify(*args)
        system('notify-send', '--icon',
          File.expand_path(
            'campfire-logo-for-fluid.png',
            File.dirname(__FILE__)),
          '-c', 'Firetower',
          *args) or raise "Desktop notification failed"
      end
    end

  end
end
