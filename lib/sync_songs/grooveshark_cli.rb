# -*- coding: utf-8 -*-

require 'highline/import'
require_relative 'grooveshark_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: A CLI for Grooveshark sets of songs.
  class GroovesharkCLI
    attr_reader :set

    def initialize
      @logged_in = false

      until @logged_in
        tryLogin
      end
    end

    private

    # Internal: Tries to login to Grooveshark and prints and error
    # message if it fails.
    def tryLogin
      @set = GroovesharkSet.new(ask('Grooveshark username? '),
                                ask('Grooveshark password? ') { |q| q.echo = false })
      @logged_in = true
    rescue Grooveshark::InvalidAuthentication => e
      say e.message
    end
  end
end
