require 'firetower/accounts'

module Firetower
  module Plugins
  end

  class Session
    include ::Firetower::Plugins
    include HookR::Hooks
    include Firetower::Accounts
    include Firetower::Rooms

    attr_reader :connections
    attr_reader :subscribed_rooms
    attr_reader :kind
    attr_reader :default_room
    attr_reader :ignore_list

    attr_accessor :logger

    define_hook :startup, :session
    define_hook :connect, :session, :account
    define_hook :join, :session, :room
    define_hook :receive, :session, :event
    define_hook :error, :session, :error
    define_hook :leave, :session, :room
    define_hook :disconnect, :session, :account
    define_hook :shutdown, :session

    def initialize(kind=:command, options={})
      @ignore_list = []
      @connections = Hash.new do |hash, subdomain|
        connection =
          if accounts[subdomain].ssl?
            connection = Net::HTTP.new("#{subdomain}.campfirenow.com", Net::HTTP.https_default_port)
            connection.use_ssl = true
            connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
            connection
          else
            Net::HTTP.new("#{subdomain}.campfirenow.com", Net::HTTP.http_default_port)
          end
        hash[subdomain] = connection
      end
      @subscribed_rooms = []
      @kind = kind
      @logger = options.fetch(:logger) { ::Logger.new($stderr) }
    end

    def ignore(*names)
      @ignore_list.concat names
    end
    # Enable a plugin or extension
    def use(class_or_instance, *args)
      case class_or_instance
      when Class then add_listener(class_or_instance.new(*args))
      else add_listener(class_or_instance)
      end
    end

    # Set default room
    def default(subdomain, room_name)
      @default_room = accounts[subdomain].rooms[room_name]
    end

    def default_room
      @default_room ||= @subscribed_rooms.first
    end

    def post(subdomain, path, data=nil)
      request = Net::HTTP::Post.new(path)
      request.body = data.to_json if data
      request['Content-Type'] = 'application/json'
      perform_request(subdomain, request)
    end

    def get(subdomain, path)
      request = Net::HTTP::Get.new(path)
      request['Accept'] = 'application/json'
      response = perform_request(subdomain, request)
      JSON.parse(response.body)
    end

    def perform_request(subdomain, request)
      request.basic_auth(accounts[subdomain].token, '')
      response = connections[subdomain].request(request)
      case response
      when Net::HTTPSuccess
        response
      when Net::HTTPClientError, Net::HTTPServerError
        raise "Error (#{response.message}): \n#{JSON.parse(response.body).to_yaml}"
      end
      response
    end

    def close!
      accounts.values.each do |account|
        account.close!
      end
    end
  end
end
