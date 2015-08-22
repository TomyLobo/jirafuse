#!/usr/bin/env ruby

require 'rfusefs'
require 'httparty'
require 'pp'
require 'deep_merge'

class Jira
    include HTTParty

    def initialize
        @config = JSON.parse File.read 'config.json'
    end

    def get(path, options = {})
        return raw_get("/rest/api/2#{path}", options.deep_merge({
            headers: {
                'Accept' => 'application/json',
            }
        }))
    end

    def raw_get(path, options = {})
        options = options.deep_merge({
            base_uri: @config['base_uri'],
            headers: {
                'X-Atlassian-Token' => 'nocheck',
            },
            basic_auth: {
                username: @config['user'],
                password: @config['password'],
            },
        })

        response = self.class.get(path, options)

        return response if (200..299).include?(response.code)

        puts 'Response:'
        puts response.to_s
        puts 'Options:'
        pp(options)
        puts "Response Code: #{response.code}"
        puts "Path: #{path}"

        raise 'hell'
    end

    def post(path, options = {})
        return raw_post("/rest/api/2#{path}", options.deep_merge({
            headers: {
                'Accept' => 'application/json',
                'Content-Type' => 'application/json',
            }
        }))
    end

    def raw_post(path, options = {})
        response = self.class.post(path, options.deep_merge({
            base_uri: @config['base_uri'],
            headers: {
                'X-Atlassian-Token' => 'nocheck',
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
