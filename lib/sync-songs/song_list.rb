# -*- coding: utf-8 -*-

require 'set'
require_relative 'song'

# Public: Classes for syncing lists of songs
module SyncSongs
  # Public: A list of songs.
  class SongList
    include Enumerable          # For +difference+

    # Public: Constructs a new list.
    #
    # *songs - If songs are provided they are added to the list
    #          (default: nil).
    def initialize(*songs)
      @songs = Set.new
      songs.each { |song| @songs << song } if songs
    end

    # Public: Adds a song to the list.
    #
    # song - The song to add to the list.
    #
    # Returns the song list to enable chaining of calls to this
    #   method.
    def add(song)
      @songs.add(song)
      self
    end

    alias_method :<<, :add

    # Public: Calls _block_ once for each element in self, passing
    # that element as a parameter. Implemented mostly for enabling the
    # +Enumerable+ mixin.
    def each(&block)
      @songs.each(&block)
    end

    # Public: Returns songs that are in the given list but not in this
    # list, i.e. songs that are exclusive to the given list.
    #
    # list - SongList to compare this list to
    def songsToAdd(list)
      list - @songs
    end

    # Public: Returns a SongList with songs that are in this list but
    # not in the given list, i.e. songs that are exclusive to this
    # list.
    #
    # list - SongList to compare this list to
    def -(list)
      @songs - list
    end

    alias_method :difference, :-

    # Public: Removes all songs from the list and returns the
    # list. Note that this only removes songs from this list and not
    # from someplace else, such as your favorites at Grooveshark.
    def clear
      @songs.clear
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
