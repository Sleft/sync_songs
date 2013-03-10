# -*- coding: utf-8 -*-

require 'highline/import'
require_relative 'grooveshark_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: A CLI for Grooveshark sets of songs.
  class GroovesharkCLI

    # Public: Creates a CLI.
    #
    # service - Service for which this is a user interface.
    # ui      - General user interface to use.
    def initialize(service, ui)
      @service = service
      @ui = ui
      @logged_in = false

      tryLogin until @logged_in
    end

    # Public: UI wrapper for library favorites. Nothing needs to be
    # done here so the call is just pass on.
    #
    # Raises Grooveshark::GeneralError if the network connection fails.
    def favorites
      @service.set.favorites
    end

    # Public: UI wrapper for addToFavorites in library. Nothing needs to be
    # done here so the call is just pass on.
    #
    # other - A SongSet to add from.
    #
    # Raises Grooveshark::GeneralError if the network connection fails.
    #
    # Returns an array of the songs that was added.
    def addToFavorites(other)
      @service.set.addToFavorites(other)
    end

    # Public: Ask for preferences of options for adding songs.
    def addPreferences
      @ui.interactive(@service)
    end

    # Public: Ask for preferences of options for searching for songs.
    def searchPreferences
      @ui.strict_search(@service)
    end

    private

    # Internal: Tries to login to Grooveshark and prints and error
    # message if it fails.
    def tryLogin
      @service.set = GroovesharkSet.new(@service.user, ask("Grooveshark password for #{@service.user}? ") { |q| q.echo = false })
      @logged_in = true
    rescue Grooveshark::InvalidAuthentication => e
      @ui.message("Grooveshark: #{e.message}")
    rescue SocketError => e
      @ui.fail('Failed to connect to Grooveshark', 1, e)
    end
  end
end
