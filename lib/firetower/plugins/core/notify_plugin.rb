require 'firetower/plugins/core/notifier_common'

module Firetower
  module Plugins
    class NotifyPlugin < Firetower::Session::Listener
      include NotifierCommon

      private
      def notify(*args)
        system('notify-send', '--icon', CAMPFIRE_LOGO,
                 '-c', 'Firetower', *args) or raise "Desktop notification failed"
      end
    end

  end
end
