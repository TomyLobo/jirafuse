#!/usr/bin/env ruby


module Routing
    def self.included(base)
        def base.route_add(verb, pattern, hash)
            hash[:to] = instance_method(hash[:to]) if hash[:to].is_a? Symbol
            @@routes ||= Hash.new { |h, k| h[k] = [] }
            @@routes[verb] << Route.new(pattern, hash)
        end
    end

    class Route
        def initialize(pattern, hash)
            @hash = hash

            # scan pattern for /:.../ (TODO: Regexp.escape the rest?)
            pattern = pattern.gsub /\/:([a-z0-9_]+)/ do
                sym = $1.to_sym

                # determine constraint
                constraint = @hash[:constraints].to_h[sym] || /[^\/]*/

                # replace by constraint
                next /\/(?<#{$1}>#{constraint})/
            end
            @regex = /^#{pattern}$/
        end

        def match(path)
            return @regex.match(path)
        end

        def dispatch(instance, params, *args)
            to = @hash[:to]

            return to.bind(instance).(params, *args) if to.is_a? UnboundMethod

            return to
        end
        
        def to_s
            return "( #{@regex} => #{@hash} )"
        end
    end # Route

    def route_dispatch(verb, path, *args)
        route, params = route_get(verb, path)
        return route.dispatch(self, params, *args) if route
        return nil
    end

    def route_get(verb, path)
        @@routes[verb].each do |route|
            params = route.match(path)
            return [ route, params ] if params
        end
        return nil
    end
    
    def route_exists?(verb, path)
        route, params = route_get(verb, path)
        return !!route
    end
end
