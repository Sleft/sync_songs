# -*- coding: utf-8 -*-

require_relative 'lastfm_cli'
require_relative 'lastfm_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controller for a Last.fm set of songs.
  class LastfmController < ServiceController

    # Public: Hash of types of services associated with what they
    # support.
    SERVICES = {loved: :rw, favorites: :rw}

    # Public: Creates a controller.
    #
    # user   - A String naming the user name or the file path for the
    #          service.
    # name   - A String naming the name of the service.
    # type   - A String naming the service type.
    # ui     - General user interface to use.
    def initialize(user, name, type, ui)
      super(user, name, type, ui)

      @service_ui = LastfmCLI.new(self, @ui)
      @set = LastfmSet.new(@service_ui.apiKey,
                           @service_ui.apiSecret,
                           @user)
    end

    # Public: Wrapper for Last.fm loved songs.
    #
    # Raises Lastfm::ApiError if the username is invalid or there is a
    #   temporary error.
    # Raises SocketError if the connection fails.
    # Raises Timeout::Error if the connection fails.
    def loved
      @set.loved
      # EXCEPTION HANDLING!!!
    end

    alias_method :favorites, :loved

    # Public: Wrapper for adding to Last.fm loved songs. Authorizes
    # the session before adding songs.
    #
    # other - A SongSet to add from.
    #
    # RESCUE!
    # Raises SocketError if the connection fails.
    def addToLoved(other)
      # Store token somewhere instead and only call URL if there is no
      # stored token.
      exit unless @service_ui.authorize(@set.authorizeURL)
      @set.authorizeSession
      @set.addToLoved(other)
      # EXCEPTION HANDLING!!!
    end

    alias_method :addToFavorites, :addToLoved

    # Public: Wrapper for searching for the given song set at Last.fm.
    #
    # other         - SongSet to search for.
    # limit         - Maximum limit for search results (default:
    #                 @set.limit).
    # strict_search - True if search should be strict (default: true).
    #
    # RESCUE THESE!
    # Raises ArgumentError from xml-simple some reason.
    # Raises Errno::EINVAL if the network connection fails.
    # Raises SocketError if the network connection fails.
    # Raises Timeout::Error if the network connection fails.
    #
    # Returns a SongSet.
    def search(other, limit = @set.limit, strict_search = true)
      @set.search(other, limit, strict_search)
    end

    # Public: Ask for preferences of options for adding songs.
    def addPreferences
      @ui.interactive(self)
    end

    # Public: Ask for preferences of options for searching for songs.
    def searchPreferences
      @ui.strict_search(self)
    end
  end
end
