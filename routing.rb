#!/usr/bin/env ruby

$routes = []

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

        send(@hash[:to], params)
        return true
    end
end


def get(pattern, hash)
    $routes << Route.new(pattern, hash)
end

def route_path(path)
    $routes.each do |route|
        success = route.dispatch(path)
        return if success
    end
end

def testfunc(params)
    puts "from testfunc: #{params}"
end

get '/issues', to: :testfunc
get '/issues/:id/comments', to: :testfunc

route_path('/issues/JFS-1/comments')
