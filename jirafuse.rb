#!/usr/bin/env ruby

require 'rfusefs'
require 'set'
require './routing'

class HelloDir
    include Routing

    def initialize
        get '/issues', to: :testfunc
        get '/issues/:id/comments', to: :testfunc
    end

    def testfunc(params)
        "from testfunc: #{params}"
    end

    @@files = Set.new [
        '/issues/:id/info',
        '/issues/:id/comments/1',
    ]

    @@directories = Set.new [
        '/issues',
        '/issues/:id/comments',
        '/issues/foo',
        '/issues/bar',
        '/foo',
        '/foo/bar',
    ]

    def contents(path)
        components = path.split('/')
        case components[0]
        when 'issues'
            return issues(components[1..-1])
        end
        
        
        return issues() if path == '/issues'
        return issues_contents(path) if path =~ /^\/issues\//
        
        path = path + '/' unless path == '/'
        @@directories
            .select { |p|
                p.start_with?(path)
            }
            .map { |p|
                p[path.length..-1]
                    .gsub(/\/.*/,'')
            }
            .to_set
    end

    def issues(components)
        return [ 'JFS-1' ] if components.empty?
    end
    
    def issues_contents()
        /^\/issues\/([^\/]*)\//
    end

    def directory?(path)
        @@directories.include?(path)
    end

    def file?(path)
        not directory?(path)
    end

    def read_file(path)
        route_path(path)
    end
end

puts HelloDir.new.read_file('/issues/JFS-1/comments')

# Usage: #{$0} mountpoint [mount_options]
#FuseFS.main() { |options| HelloDir.new }
