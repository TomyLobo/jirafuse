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

    def can_write?(path)
        route_exists? :write, path
    end

    def write_to(path, contents)
        route_dispatch :write, path, contents
    end

    def size(path)
        route_dispatch(:size, path) || read_file(path).length
    end

    def times(path)
        route_dispatch(:times, path) || FuseFS::FuseDir::INIT_TIMES
    end
end
