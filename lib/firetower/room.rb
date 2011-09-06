module Firetower
  class Room
    attr_reader :id, :name, :account

    def initialize(account, attributes={})
      @account = account
      @id      = attributes['id']
      @name    = attributes['name']
    end

    def to_s
      "#{account.subdomain}/#{id} (#{name})"
    end

    def say!(message)
      account.say!(name, message)
    end

    def paste!(message)
      account.paste!(name, message)
    end
    
    def play!(message)
      account.play!(name, message)
    end
  end
end
