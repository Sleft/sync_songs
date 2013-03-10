# -*- coding: utf-8 -*-

require 'highline/import'
require 'launchy'
require_relative 'lastfm_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controller for a Last.fm set of songs.
  class LastfmController

    # Public: Creates a controller.
    #
    # service - Service for which this is a controller.
    # ui      - General user interface to use.
    def initialize(service, ui)
      @service = service
      @ui = ui
      # PUT IN CLI!!!!
      @service.set = LastfmSet.new(ask("Last.fm API key for #{@service.user} #{@service.name} #{@service.type}? ") { |q| q.echo = false },
                           ask("Last.fm API secret for #{@service.user} #{@service.name} #{@service.type}? ") { |q| q.echo = false },
                           @service.user)
    end

    # Public: Wrapper for Last.fm loved songs.
    #
    # Raises Lastfm::ApiError if the username is invalid or there is a
    #   temporary error.
    # Raises SocketError if the connection fails.
    # Raises Timeout::Error if the connection fails.
    def loved
      @service.set.loved
      # EXCEPTION HANDLING!!!
    end

    alias_method :favorites, :loved

    # Public: Wrapper for adding to Last.fm loved songs. Authorizes
    # the session before adding.
    #
    # other - A SongSet to add from.
    #
    # Raises SocketError if the connection fails.
    def addToLoved(other)
      # Store token somewhere instead and only call URL if there is no
      # stored token.
      # MOVE TO CLI!!!
      Launchy.open(@service.set.authorizeURL)
      exit unless ask('A page asking for authorization with Last.fm should be open in your web browser. You need to approve it before proceeding. Continue? (y/n) ').casecmp('y') == 0
      @service.set.authorize
      @service.set.addToLoved(other)
      # EXCEPTION HANDLING!!!
    end

    alias_method :addToFavorites, :addToLoved

    # Public: Ask for preferences of options for adding songs.
    def addPreferences
      @ui.interactive(@service)
    end

    # Public: Ask for preferences of options for searching for songs.
    def searchPreferences
      @ui.strict_search(@service)
    end
  end
end
