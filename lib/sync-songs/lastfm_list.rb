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
    #
    # Raises XXXXXXXXXX if authentication
    #   fails.
    def initialize(username, password)
      super()

      # Setup a Last.fm session
      api_key = 'cd7095c6346889798024d5bddb730f97'
      api_secret = 'f70776693c09fde4ebf220a3d7d9a0f7'
      @lastfm = Lastfm.new(api_key, api_secret)

      # Store token somewhere instead and only call URL if there is no
      # stored token.
      token = @lastfm.auth.get_token      Launchy.open("http://www.last.fm/api/auth/?api_key=#{api_key}&token=#{token}")


      @lastfm.session = @lastfm.auth.get_session(:token => token)['key']
    end

    # Public: Get the user's favorites from Last.fm
    def getFavorites
      # @user.favorites.each do |s|
      #   add(Song.new(s.name, s.artist, s.album))
      # end
    end
  end

  list = LastfmList.new('','')
end
