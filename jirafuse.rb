#!/usr/bin/env ruby

require 'rfusefs'

require './jiradir'

# Usage: #{$0} mountpoint [mount_options]
FuseFS.main() { |options| JiraDir.new }
