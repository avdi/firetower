module Firetower
  module Accounts
    fattr(:account_fetcher) {
      Account.method(:new)
    }
    fattr(:accounts) {
      Hash.new do |hash, subdomain|
        raise "Unknown subdomain '#{subdomain}'"
      end
    }

    # Eventually advances to HookR will render all this reduundant
    def self.extended(other)
      class << other
        include HookR::Hooks
        define_hook :new_account, :subdomain, :token, :options
      end
    end

    def self.included(other)
      other.module_eval do
        include HookR::Hooks
        define_hook :new_account, :subdomain, :token, :options
      end
    end

    # Declare an account
    def account(subdomain, token, options={})
      execute_hook(:new_account, subdomain, token, options)
      accounts[subdomain] = account_fetcher.call(subdomain, token, self, options)
    end

    def find_room(subdomain, room_name)
      accounts[subdomain].rooms[room_name]
    end

  end
end
