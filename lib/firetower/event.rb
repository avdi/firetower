module Firetower
  class Event
    attr_accessor :attributes
    attr_accessor :room
    attr_accessor :created_at, :body, :id, :user_id, :type

    def self.parse(json)
      new(JSON.parse(json))
    end

    def initialize(attributes)
      @attributes = attributes
      @attributes.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
    end

    def [](key)
      @attributes[key]
    end

    def []=(key, value)
      @attributes[key] = value
    end

    def text?
      self.type == 'TextMessage'
    end

    def sound?
      self.type == 'SoundMessage'
    end

    def timestamp?
      self.type == 'TimestampMessage'
    end

    def =~(pattern)
      self.body =~ pattern
    end

  end
end
