# -*- coding: utf-8 -*-

require 'test/unit'
require_relative '../../../lib/sync_songs/services/csv_set'
require_relative '../sample_data/sample_data'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Internal: Unit test for the class CSVSet.
  class TestCSVSet < Test::Unit::TestCase
    include SampleData

    # Internal: Setup a Last.fm session.
    def setup
      setupTestSongs
      @set = CSVSet.new('test_csvset.csv')
    end

    def test_library
      # First write to a CSV file.
      @set.addToLibrary(@songs)

      # Then get data from it.
      l = @set.library

      # Put the input to the CSV file in a SongSet
      s = SongSet.new(*@songs)

      # It should be the same as what is read from the CSV file.
      diff = l.exclusiveTo(s)
      assert(diff.empty?, 'Should not corrupt data')
    end

    # def test_search
    #   other = SongSet.new(Song.new('Play With Fire', 'Dead Moon', 'Strange Pray Tell'))
    #   result = @set.search(other)
    #   assert(result.include?(Song.new('Play With Fire', 'Dead Moon', 'Strange Pray Tell')))
    # end

    # def test_addToLibrary
    #   @set.addToLibrary(@songs)
    # end
  end
end
