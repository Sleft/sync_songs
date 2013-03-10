# -*- coding: utf-8 -*-

require_relative 'grooveshark_cli'
require_relative 'grooveshark_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controller for a Grooveshark set of songs.
  class GroovesharkController < ServiceController

    # Public: Hash of types of services associated with what they
    # support.
    SERVICES = {favorites: :rw}

    # Public: Creates a controller.
    #
    # user   - A String naming the user name or the file path for the
    #          service.
    # name   - A String naming the name of the service.
    # type   - A String naming the service type.
    # ui     - General user interface to use.
    def initialize(user, name, type, ui)
      super(user, name, type, ui)

      @service_ui = GroovesharkCLI.new(self, @ui)

      @logged_in = false
      tryLogin until @logged_in
    end

    # Public: Wrapper for Grooveshark favorites.
    #
    # Raises Grooveshark::GeneralError if the network connection fails.
    def favorites
      @set.favorites
      # EXCEPTION HANDLING!!!
    end

    # Public: Wrapper for adding to Grooveshark favorites.
    #
    # other - A SongSet to add from.
    #
    # RESCUE
    # Raises Grooveshark::GeneralError if the network connection
    #   fails.
    #
    # Returns an array of the songs that was added.
    def addToFavorites(other)
      @set.addToFavorites(other)
    end

    # Public: Wrapper for searching for the given song set at
    # Grooveshark.
    #
    # other         - SongSet to search for.
    # strict_search - True if search should be strict (default: true).
    #
    # Raises Grooveshark::GeneralError if the network connection
    #   fails.
    #
    # Returns a SongSet.
    def search(other, strict_search = true)
      @set.search(other, strict_search = true)
    end

    # Public: Ask for preferences of options for adding songs.
    def addPreferences
      @ui.interactive(self)
    end

    # Public: Ask for preferences of options for searching for songs.
    def searchPreferences
      @ui.strict_search(self)
    end

    private

    # Internal: Tries to login to Grooveshark and prints and error
    # message if it fails.
    def tryLogin
      @set = GroovesharkSet.new(@user, @service_ui.password)
      @logged_in = true
    rescue Grooveshark::InvalidAuthentication => e
      @ui.message("Grooveshark: #{e.message}")
    rescue SocketError => e
      @ui.fail('Failed to connect to Grooveshark', 1, e)
    end
  end
end
