# -*- coding: utf-8 -*-

require 'rubygems'
require 'grooveshark'
require_relative 'song_list'

# Public: Classes for syncing lists of songs
module SyncSongs
  # Public: A list of Grooveshark songs.
  class GroovesharkList < SongList

    # Public: Constructs a Grooveshark list by logging in to
    # Grooveshark with the specified user.
    #
    # username - The username of the user to authenticate
    # password - The password of the user to authenticate
    #
    # Raises Grooveshark::InvalidAuthentication if authentication
    #   fails.
    def initialize(username, password)
      super()

      # Setup a Grooveshark session
      @client = Grooveshark::Client.new
      @session = @client.session

      # Try to authenticate the given user.
      begin
        @user = @client.login(username, password)
      rescue Grooveshark::InvalidAuthentication => e
        $stderr.puts "#{e.message} An authenticated user is required for getting data from Grooveshark."
        raise
      end
    end

    # Public: Get the user's favorites from Grooveshark.
    def getFavorites
      @user.favorites.each { |s| add(Song.new(s.name, s.artist, s.album)) }
    end

    # Public: Add the songs in the given list to the user's favorite
    # on Grooveshark.
    #
    # username - The username of the user to authenticate
    # list     - SongList to add from
    def addToFavorites(username, list)
      to_add = songsToAdd(list)
      # For each song in to_add
      #   find and store all its hits
      #   add as favorite
      #   print it if verbose
    end
  end
end
