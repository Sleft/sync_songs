# -*- coding: utf-8 -*-

require 'set'
require_relative 'song'

# Public: Classes for syncing lists of songs.
module SyncSongs
  # Public: A list of songs.
  class SongList
    include Enumerable      # Several traversal and searching methods.

    # Public: Constructs a new list.
    #
    # *songs - If songs are provided they are added to the list
    #          (default: nil).
    def initialize(*songs)
      @songs = Set.new
      songs.each { |song| @songs << song } if songs
    end

    # Public: Adds the given song to the list and returns self.
    def add(song)
      @songs.add(song)
      self
    end

    alias_method :<<, :add

    # Public: Adds the given song to the list and returns self or nil
    # if the song is already in the list.
    #
    # Returns the song list to enable chaining of calls to this
    #   method.
    def add?(song)
      include?(song) ? nil : add(song)
    end

    # Public: Calls _block_ once for each element in self, passing
    # that song as a parameter.
    def each(&block)
      @songs.each(&block)
    end

    # Public: Returns songs that are in the given list but not in this
    # list, i.e. songs that are exclusive to the given list.
    #
    # other - SongList to compare this list to.
    def exclusiveTo(other)
      other - @songs
    end

    # Public: Returns a SongList with songs that are in this list but
    # not in the given list, i.e. songs that are exclusive to this
    # list.
    #
    # other - SongList to compare this list to.
    def -(other)
      @songs - other
    end

    alias_method :difference, :-

    # Public: Removes all songs from the list and returns the
    # list. Note that this only removes songs from this list and not
    # from someplace else, such as your favorites at Grooveshark.
    def clear
      @songs.clear
    end

    # Public: Returns true if the list contains no song.
    def empty?
      @songs.empty?
    end

    # Public: Returns a string containing a human-readable
    # representation of the set.
    def inspect
      @songs.inspect
    end

    # Public: Returns the number of songs.
    def size
      @songs.size
    end

    alias_method :length, :size
  end
end
