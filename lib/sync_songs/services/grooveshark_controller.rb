# -*- coding: utf-8 -*-

require_relative 'grooveshark_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controller for a Grooveshark set of songs.
  class GroovesharkController

    # Public: Creates a controller.
    #
    # service - Service for which this is a controller.
    # ui      - General user interface to use.
    def initialize(service, ui)
      @service = service
      @ui = ui
      @service_ui = GroovesharkCLI.new(self, @ui)

      @logged_in = false
      tryLogin until @logged_in
    end

    # Public: Wrapper for Grooveshark favorites.
    #
    # Raises Grooveshark::GeneralError if the network connection fails.
    def favorites
      @service.set.favorites
      # EXCEPTION HANDLING!!!
    end

    # Public: Wrapper for adding to Grooveshark favorites.
    #
    # other - A SongSet to add from.
    #
    # Raises Grooveshark::GeneralError if the network connection
    #   fails.
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
      @service.set = GroovesharkSet.new(@service.user, @service_ui.password)
      @logged_in = true
    rescue Grooveshark::InvalidAuthentication => e
      @ui.message("Grooveshark: #{e.message}")
    rescue SocketError => e
      @ui.fail('Failed to connect to Grooveshark', 1, e)
    end
  end
end
