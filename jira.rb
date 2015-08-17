#!/usr/bin/env ruby

require 'rfusefs'
require 'httparty'

class Jira
    include HTTParty

    def initialize
        @config = JSON.parse File.read 'config.json'
    end

    def get(path, options = {})
        self.class.get(path, options.merge({
            base_uri: "#{@config['base_uri']}/rest/api/2",
            basic_auth: {
                username: @config['user'],
                password: @config['password'],
            },
        }))
    end
end
