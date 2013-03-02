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
      @file_name = 'test_csvset.csv'
      @set = CSVSet.new(@file_name)
    end

    def test_simple
      # Add some songs to CSV
      @set.addToLibrary(SongSet.new(@songs[0], @songs[8]))

      assert(File.exists?(@file_name), 'Should create a file')

      # Then get data from it.
      l = @set.library
      assert_not_nil(l, 'Should read something from CSV')
      assert(l.member?(@songs[0]), 'Reading from CSV should not corrupt data')
      assert(l.member?(@songs[8]), 'Reading from CSV should not corrupt data')

      assert_equal(l, @set.search(l), 'Should simply return what is searched for')
    end
  end
end
