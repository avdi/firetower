module Firetower
  class Event
    attr_accessor :attributes
    attr_accessor :room

    def self.parse(json)
      new(JSON.parse(json))
    end

    def initialize(attributes)
      @attributes = attributes
    end

    def [](key)
      @attributes[key]
    end

    def []=(key, value)
      @attributes[key] = value
    end
  end
end
