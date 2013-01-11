# -*- coding: utf-8 -*-

require 'rubygems'
require 'grooveshark'
require_relative 'song_list'

# Public: Classes for syncing lists of songs
module SyncSongs
  # Public: A list of Grooveshark songs.
  class GroovesharkList < SongList

    # Public: Constructs a Grooveshark list by logging in to
    # Grooveshark with the given user.
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

      login(username, password)
    end

    # Public: Get the user's favorites from Grooveshark.
    def getFavorites
      @user.favorites.each { |s| add(Song.new(s.name, s.artist)) }
    end

    # Public: Add the songs in the given list to the user's favorite
    # on Grooveshark.
    #
    # other - SongList to add from
    #
    # Returns the songs that was added.
    def addToFavorites(other)
      songs_to_add = songsToAdd(other)
      # For each song in songs_to_add
      #   find and store all its hits
      #   add as favorite
      #   print it if verbose
      # Return the songs that was added.
    end

    # Public: Searches for favorite candidates at Grooveshark.
    #
    # other - SongList to search for.
    # strict_search - True if search should be strict (default: true).
    #
    # Returns a hash of Grooveshark ids associated the favorite
    #   candidates.
    def getFavoriteCandidates(other, strict_search = true)
      candidates = {}

      other.each do |song|
        @client.search_songs(song.to_search_term).each do |found_song|
          other = Song.new(found_song.name, found_song.artist)
          if strict_search
            next unless song.eql?(other)
          else
            next unless song.similar?(other)
          end
          candidates[found_song.id] = other
        end
      end
      candidates
    end

    private

    # Internal: Tries to login to Grooveshark with the given user.
    #
    # username - The username of the user to authenticate
    # password - The password of the user to authenticate
    #
    # Raises Grooveshark::InvalidAuthentication if authentication
    #   fails.
    def login(username, password)
      @user = @client.login(username, password)
    rescue Grooveshark::InvalidAuthentication => e
      $stderr.puts "#{e.message} An authenticated user is required for getting data from Grooveshark."
      raise
    end
  end
end
