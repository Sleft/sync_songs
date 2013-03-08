# -*- coding: utf-8 -*-

require 'test/unit'
require_relative '../../../lib/sync_songs/services/csv_set'
require_relative '../sample_data/sample_data'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Internal: Unit test for the class CSVSet.
  class TestCSVSet < Test::Unit::TestCase
    include SampleData

    # Internal: Setup CSVSets.
    def setup
      setupTestSongs
      @file_names = []
      1.upto(2) do |i|
        @file_names << "test/unit/services/sample_data/test_csv_set_sample#{i}.csv"
      end

      @sets = []
      @file_names.each { |n| @sets << CSVSet.new(n) }
    end

    def test_simple
      # Add some songs to CSV files
      @sets[0].addToLibrary(SongSet.new(@songs[0], @songs[8]))
      @sets[1].addToLibrary(SongSet.new(@songs[0], @songs[7]))

      assert(File.exists?(@file_names[0]), 'Should create a file')

      # Then get data from them.
      @lib = []
      @sets.each { |s| @lib << s.library }

      # Should work as expected.
      assert(@lib[0].member?(@songs[0]), 'Reading from CSV should not corrupt data')
      assert(@lib[0].member?(@songs[8]), 'Reading from CSV should not corrupt data')
      @lib.each do |l|
        assert_not_nil(l, 'Should read something from CSV')
        assert_equal(l, l.search(l), 'Search should simply return what is searched for')
      end

      ex_to_l0 = @lib[0].exclusiveTo(@lib[1])
      exl_msg = 'exclusiveTo works as expected'
      assert(ex_to_l0.size == 1, exl_msg)
      assert_equal(ex_to_l0, Set.new([@songs[7]]), exl_msg)
    end
  end
end
