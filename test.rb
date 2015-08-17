#!/usr/bin/env ruby

$routes = {}


def get(pattern, hash)
    $routes[pattern] = hash
    puts pattern
    puts hash
    send(hash[:to])
end

def testfunc
    puts 'from testfunc'
end


get '/issues', to: :testfunc
get '/issues/:id/comments', to: :testfunc


mypath = '/issues/JFS-1/comments'

$routes.each do |pattern, hash|
    # TODO:
    # scan pattern for /: (Regexp.escape the rest?)
    # replace by ([^/]*)
    # store order
    # match mypath
    # assign to params dict by order
    #pattern.matches
end
