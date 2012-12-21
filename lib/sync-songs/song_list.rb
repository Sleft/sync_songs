# -*- coding: utf-8 -*-

require 'set'
require_relative './song'

module SyncSongs
  ##
  # Stores a list of songs.
  class SongList
    include Enumerable          # For +difference+

    ##
    # Constructs a new song list.
    def initialize
      @songs = Set.new
    end

    ##
    # Adds a song to the end of the list.
    def add(song)
      @songs.add(song)
      self                     # To enable chaining of calls to +add+
    end

    ##
    # Calls _block_ once for each element in self, passing that
    # element as a parameter. Implemented mostly for enabling the
    # +Enumerable+ mixin.
    def each(&block)
      @songs.each(&block)
    end

    ##
    # Returns songs that are in this list but not in the given list.
    def -(compared_list)
      @songs - compared_list
    end

    alias_method :difference, :-
  end
end
