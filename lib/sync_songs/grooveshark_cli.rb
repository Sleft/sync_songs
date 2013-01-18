# -*- coding: utf-8 -*-

require 'highline/import'
require_relative 'grooveshark_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: A CLI for Grooveshark sets of songs.
  class GroovesharkCLI
    attr_reader :set

    def initialize
      @set = GroovesharkSet.new(ask('Grooveshark username? '),
                                ask('Grooveshark password? ') { |q| q.echo = false })
    end
  end
end
