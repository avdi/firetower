module Firetower
  module Plugins
    class NotifyPlugin < Firetower::Session::Listener
      def initialize(options={})
        @notifier = options.fetch(:notifier) { method(:notify) }
        @ignore_list = options.fetch(:ignore_list) { [] }
      end

      def startup(session)
        if session.kind == :server
          notify("Firetower", "Firetower is vigilantly scanning the treetops")
        end
        @ignore_list.concat session.ignore_list
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
          @notifier.call(user['name'], event['body']) unless ignored?(user['name'])

        else
          # NOOP
        end
      end

      def error(session, error)
        notify("Campfire Error", error.message)
      end

      private
      def ignored?(user_name)
        !@ignore_list.grep(user_name).empty?
      end

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
