#!/usr/bin/env ruby

require 'time'

class Cache
    class Entry
        attr_reader :value, :creation_time

        def initialize(value)
            @creation_time = Time.now
            @value = value
        end
    end

    def initialize
        @entries = {}
    end

    def get(key, max_age, &block)
        entry = @entries[key]
        if entry and Time.now - entry.creation_time < max_age
            puts "Returning cached key #{key}"
            return entry.value
        end

        puts "Requesting #{key}"
        value = block.call(key)
        @entries[key] = Entry.new(value)
        return value
    end
end
