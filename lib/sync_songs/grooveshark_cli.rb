# -*- coding: utf-8 -*-

require 'highline/import'
require_relative 'grooveshark_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: A CLI for Grooveshark sets of songs.
  class GroovesharkCLI
    attr_reader :set

    # Public: Construct a CLI.
    #
    # service - Service for which this is a user interface.
    # ui      - General user interface to use.
    def initialize(service, ui)
      @service = service
      @ui = ui
      @logged_in = false

      until @logged_in
        tryLogin
      end
    end

    # Public: UI wrapper for library favorites. Nothing needs to be
    # done here so the call is just pass on.
    def favorites
      @set.favorites
    end

    # Public: UI wrapper for addToFavorites in library. Nothing needs to be
    # done here so the call is just pass on.
    #
    # other - A SongSet to add from.
    #
    # Returns an array of the songs that was added.
    def addToFavorites(other)
      @set.addToFavorites(other)
    end

    # Public: Ask for preferences of options for adding songs.
    def addPreferences
      @ui.strict_search(@service)
      @ui.interactive(@service)
    end

    private

    # Internal: Tries to login to Grooveshark and prints and error
    # message if it fails.
    def tryLogin
      @set = GroovesharkSet.new(ask('Grooveshark username? '),
                                ask('Grooveshark password? ') { |q| q.echo = false })
      @logged_in = true
    rescue Grooveshark::InvalidAuthentication => e
      say "Grooveshark: #{e.message}"
    rescue SocketError => e
      @ui.fail('Failed to connect to Grooveshark', e)
    end
  end
end
