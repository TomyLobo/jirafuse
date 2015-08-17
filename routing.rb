#!/usr/bin/env ruby

$routes = []

module Routing
    class Route
        def initialize(pattern, hash)
            @hash = hash
            @keys = []

            # scan pattern for /:.../ (TODO: Regexp.escape the rest?)
            pattern = pattern.gsub(/\/:([^\/]+)\//) {
                # store matches in order
                @keys << $1.to_sym

                # replace by /([^/]*)/
                '/([^/]*)/'
            }
            @regex = /^#{pattern}$/
        end

        def match(path)
            # match path
            match = @regex.match(path)
            return nil unless match
            # assign to params dict by order
            Hash[@keys.zip(match.captures)]
        end

        def dispatch(path)
            params = match(path)
            return false unless params

            @hash[:to].call params
        end
    end

    def get(pattern, hash)
        hash[:to] = method(hash[:to])
        $routes << Route.new(pattern, hash)
    end

    def route_path(path)
        $routes.each do |route|
            ret = route.dispatch(path)
            return ret if ret
        end
    end
end
