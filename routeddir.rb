#!/usr/bin/env ruby

require './routing'

class RoutedDir
    include Routing

    def contents(path)
        route_dispatch :list, path
    end

    def directory?(path)
        route_exists? :list, path
    end

    def file?(path)
        route_exists? :read, path
    end

    def read_file(path)
        route_dispatch :read, path
    end
end
