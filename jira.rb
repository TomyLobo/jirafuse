#!/usr/bin/env ruby

require 'rfusefs'
require 'httparty'

class Jira
    include HTTParty
    base_uri 'http://localhost:8080/rest/api/2'

    def initialize
        @config = JSON.parse File.read 'config.json'
    end

    def get(path, options = {})
        self.class.get(path, options.merge({
            basic_auth: {
                username: @config['user'],
                password: @config['password'],
            },
        }))
    end
end
