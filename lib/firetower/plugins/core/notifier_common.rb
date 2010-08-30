module Firetower
  module Plugins

    module NotifierCommon

      CAMPFIRE_LOGO = File.expand_path('campfire-logo-for-fluid.png', File.dirname(__FILE__))
      
      def initialize(options={})
        @notifier = options.fetch(:notifier) { method(:notify) }
        @ignore_list = options.fetch(:ignore_list) { [] }
      end
      
      def error(session, error)
        notify("Campfire Error", error.message, 'Error')
      end

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
          @notifier.call(user['name'], event['body'], event.room.name) unless ignored?(user['name'])
        else
          # NOOP
        end
      end
      
      private
      def ignored?(user_name)
        !@ignore_list.grep(user_name).empty?
      end
      
      
    end

  end
end