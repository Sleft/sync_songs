# -*- coding: utf-8 -*-

require 'set'
require_relative './song'

# Public: Classes for syncing lists of songs
module SyncSongs
  # Public: Stores a list of songs.
  class SongList
    include Enumerable          # For +difference+

    # Public: Constructs a new song list.
    def initialize
      @songs = Set.new
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

    # Public: Calculates which songs are in this list but not the compared
    # list.
    #
    # compared_list Song list to compare this list to.
    #
    # Returns songs that are in this list but not in the compared
    #   list.
    def -(compared_list)
      @songs - compared_list
    end

    alias_method :difference, :-
  end
end
