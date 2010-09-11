module Firetower
  module Accounts
    include HookR::Hooks

    fattr(:account_fetcher) {
      Account.method(:new)
    }
    fattr(:accounts) {
      Hash.new do |hash, subdomain|
        raise "Unknown subdomain '#{subdomain}'"
      end
    }

    define_hook :new_account, :subdomain, :token, :options

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
