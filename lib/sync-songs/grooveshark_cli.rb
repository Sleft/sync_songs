# -*- coding: utf-8 -*-

require 'highline/import'
require_relative 'grooveshark_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: A CLI for Grooveshark sets of songs.
  class GroovesharkCLI
    def initialize
      p username = ask('Grooveshark username? ')
      password = ask('Grooveshark password? ') { |q| q.echo = false }
      @set = GroovesharkSet.new(username, password)
    end
  end

  var = GroovesharkCLI.new
end
