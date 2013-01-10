# -*- coding: utf-8 -*-

require 'rubygems'
require 'lastfm'
require 'launchy'
require_relative 'song_list'

# Public: Classes for syncing lists of songs
module SyncSongs
  # Public: A list of Grooveshark songs.
  class LastfmList < SongList

    # Public: Constructs a Last.fm list by logging in to
    # Last.fm with the specified user.
    #
    # username - The username of the user to authenticate
    # password - The password of the user to authenticate
    def initialize(api_key, api_secret)
      super()
      @api_key = api_key
      @lastfm = Lastfm.new(api_key, api_secret)
    end

    # Public: Get the user's loved songs from Last.fm.
    #
    # username - The username of the user to authenticate
    # limit    - The maximum number of favorites to get
    #
    # Raises Lastfm::ApiError if the username is invalid.
    def getLoved(username, limit)
      @lastfm.user.get_loved_tracks(:user => username, :api_key => @api_key, :limit => limit).each do |s|
        add(Song.new(s['name'], s['artist']['name'], '')) # Last.fm loved track does not include an album field
      end
    end

    # Public: Add the songs in the given list to the given user's
    # loved songs on Last.fm.
    #
    # username - The username of the user to authenticate
    # list     - SongList to add from
    #
    # Yields the songs_to_add, i.e. the songs that are not already in
    #   this list, if a block is given.
    #
    # Raises Lastfm::ApiError if the username is invalid or if the
    #   Last.fm token has not been authorized.
    def addToLoved(username, list)
      authorize
      songs_to_add = songsToAdd(list)
      yield songs_to_add if block_given?
      # For each song in songs_to_add
      #   find and store all its hits
      #   add as favorite
      #   print it if verbose
    end

    private

    def authorize
      # Store token somewhere instead and only call URL if there is no
      # stored token.
      token = @lastfm.auth.get_token
      Launchy.open("http://www.last.fm/api/auth/?api_key=#@api_key&token=#{token}")
      print 'A page asking for authorization of this tool with Last.fm should be open in your web browser. You need to approve it before proceeding. Continue? (y/n) '
      exit unless gets.strip.casecmp('y') == 0

      @lastfm.session = @lastfm.auth.get_session(:token => token)['key']
    end
  end
end
