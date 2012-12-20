# -*- coding: utf-8 -*-

require 'set'
# require_relative 'song'
require './song'

module SyncFavSongs
  ##
  # Stores a list of songs.
  class SongList
    include Enumerable          # For +include?+

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

  # Gör riktigt test av detta! Se pickaxe
  song1 = Song.new("1", "")
  song2 = Song.new("2", "")
  song3 = Song.new("3", "")
  song4 = Song.new("4", "")
  song5 = Song.new("5", "")
  song6 = Song.new("6", "")

  # puts song1.eql?(song2)
  # puts song1.eql?(song3)
  # puts song2.eql?(song3)

  list1 = SongList.new
  list1.add(song1).add(song3).add(song5).add(song1)
  list2 = SongList.new
  list2.add(song1).add(song2).add(song3).add(song4).add(song6)

  puts list2.difference(list1).to_a
end
