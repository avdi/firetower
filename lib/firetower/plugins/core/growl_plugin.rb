require 'firetower/plugins/core/notifier_common'

module Firetower
  module Plugins
    class GrowlPlugin < Firetower::Session::Listener
      include NotifierCommon

      private

      def notify(*args)
        system('growlnotify', '-t', (args[2].nil? ? args[0] : "#{args[0]} - #{args[2]}"), 
          '-m', args[1], '--image', CAMPFIRE_LOGO) \
            or raise "Growl notification failed"
      end
    end
  end
end
