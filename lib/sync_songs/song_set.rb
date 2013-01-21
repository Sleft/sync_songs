# -*- coding: utf-8 -*-

require 'delegate'
require 'set'
require_relative 'song'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: A set of songs.
  class SongSet < SimpleDelegator

    # Public: Constructs a new set.
    #
    # *songs - If songs are provided they are added to the set
    #          (default: nil).
    def initialize(*songs)
      @songs = Set.new
      super(@songs)
      songs.each { |song| @songs << song } if songs
    end

    # Public: Returns songs that are in the given list but not in this
    # list, i.e. songs that are exclusive to the given list.
    #
    # other - SongList to compare this list to.
    def exclusiveTo(other)
      other - @songs
    end
  end
end
