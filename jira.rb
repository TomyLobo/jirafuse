#!/usr/bin/env ruby

require 'rfusefs'
require 'httparty'
require 'pp'

class Jira
    include HTTParty

    def initialize
        @config = JSON.parse File.read 'config.json'
    end

    def get(path, options = {})
        response = self.class.get(path, options.merge({
            base_uri: "#{@config['base_uri']}/rest/api/2",
            headers: {
                'Accept' => 'application/json',
            },
            basic_auth: {
                username: @config['user'],
                password: @config['password'],
            },
        }))

        return response if (200..299).include?(response.code)

        puts 'Response:'
        puts response.to_s
        puts 'Options:'
        pp(options)
        puts "Response Code: #{response.code}"
        puts "Path: #{path}"

        raise 'hell'
    end
end
