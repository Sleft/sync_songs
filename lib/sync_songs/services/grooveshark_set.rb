# -*- coding: utf-8 -*-

require 'grooveshark'
require_relative '../song_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: A set of Grooveshark songs.
  class GroovesharkSet < SongSet
    # Public: Hash of types of services associated with what they
    # support.
    SERVICES = {favorites: :rw}

    # Public: Creates a Grooveshark set by logging in to Grooveshark
    # with the given user.
    #
    # username - The username of the user to authenticate.
    # password - The password of the user to authenticate.
    #
    # Raises Grooveshark::InvalidAuthentication if authentication
    #   fails.
    # Raises SocketError if the network connection fails.
    def initialize(username, password)
      super()

      # Setup a Grooveshark session.
      @client = Grooveshark::Client.new
      @session = @client.session

      login(username, password)
    end

    # Public: Get the user's favorites from Grooveshark.
    #
    # Raises Grooveshark::GeneralError if the network connection fails.
    #
    # Returns self.
    def favorites
      @user.favorites.each { |s| add(Song.new(s.name, s.artist, s.album)) }
      self
    end

    # Public: Add the songs in the given set to the user's favorite
    # on Grooveshark.
    #
    # other - A SongSet to add from.
    #
    # Raises Grooveshark::GeneralError if the network connection fails.
    #
    # Returns an array of the songs that was added.
    def addToFavorites(other)
      songsAdded = []

      other.each do |s|
        songsAdded << s if s.id && @user.add_favorite(s.id)
      end

      songsAdded
    end

    # Public: Searches for the given song set at Grooveshark.
    #
    # other         - SongSet to search for.
    # strict_search - True if search should be strict (default: true).
    #
    # Raises Grooveshark::GeneralError if the network connection
    #   fails.
    #
    # Returns a SongSet.
    def search(other, strict_search = true)
      result = SongSet.new

      # Search for songs that are not already in this set and return
      # them if they are sufficiently similar.
      other.each do |song|
        @client.search_songs(song.to_search_term).each do |s|
          other = Song.new(s.name, s.artist, s.album,
                           Float(s.duration), s.id)

          if strict_search
            next unless song.eql?(other)
          else
            next unless song.similar?(other)
          end
          result << other
        end
      end
      result
    end

    private

    # Internal: Tries to login to Grooveshark with the given user.
    #
    # username - The username of the user to authenticate.
    # password - The password of the user to authenticate.
    #
    # Raises Grooveshark::InvalidAuthentication if authentication
    #   fails.
    def login(username, password)
      @user = @client.login(username, password)
    rescue Grooveshark::InvalidAuthentication => e
      raise Grooveshark::InvalidAuthentication, "#{e.message} An authenticated user is required for getting data from Grooveshark"
      raise
    end
  end
end
