# -*- coding: utf-8 -*-

require 'test/unit'
require_relative '../../lib/sync-songs/song_list'
require_relative 'sample_data/sample_data'

# Public: Classes for syncing lists of songs.
module SyncSongs
  # Private: Unit test for the class SongList.
  class TestSongList < Test::Unit::TestCase
    include SampleData

    def setup
      setupTestSongs
    end

    def test_size
      list = SongList.new
      list << @songs[0]

      size_msg = 'Should return list\'s size'
      assert(list.size == 1, size_msg)
      assert(list.length == 1, size_msg)
    end

    def test_simple
      lists = [SongList.new, SongList.new]

      init_msg = 'Song lists should initialize'
      assert_not_nil(lists[0], init_msg)
      assert_not_nil(lists[1], init_msg)
    end

    def test_add
      lists = [SongList.new(@songs[0]), SongList.new(@songs[0])]

      add_msg = 'A song list should not manipulate its content'
      assert_equal(@songs[0], lists[0].first, add_msg)
      assert_equal(@songs[0], lists[1].first, add_msg)
      assert(lists[0].member?(@songs[0]), add_msg)
      assert(lists[1].member?(@songs[0]), add_msg)
    end

    def test_difference
      lists = [SongList.new(@songs[0]), SongList.new(@songs[0])]

      diff_eql_msg = 'There is no difference between sets with the same members'
      assert(lists[0].difference(lists[1]).empty?, diff_eql_msg)
      assert(lists[1].difference(lists[0]).empty?, diff_eql_msg)

      lists[0].add(@songs[1])  # lists[0] = {@songs[0], @songs[1]}
      lists[1].add(@songs[2])  # lists[1] = {@songs[0], @songs[2]}
      assert(!(lists[0] - lists[1]).member?(@songs[0]), 'The difference is not the shared element')

      diff_msg = 'The difference is the non-shared element in the receiver'
      assert((lists[0] - lists[1]).member?(@songs[1]), diff_msg)
      assert((lists[1] - lists[0]).member?(@songs[2]), diff_msg)
      lists[0].add(@songs[2]) # lists[0] = {@songs[0], @songs[1], @songs[2]}
      assert((lists[0] - lists[1]).member?(@songs[1]), diff_msg)
      assert((lists[1] - lists[0]).empty?, diff_msg)

      lists[2] = SongList.new(@songs[0], @songs[1], @songs[2])
      lists[3] = SongList.new(@songs[2], @songs[0], @songs[1])
      assert((lists[2] - lists[3]).empty?, 'There is no difference between sets with the same members that has been added in different order')
      assert((lists[2] - lists[3]).empty?, 'The alias - for difference should work')

      lists[2].add(@songs[0])
      lists[3].add(@songs[2])
      assert((lists[2] - lists[3]).empty?, 'There are no duplicate entries')

      lists[2].add(@songs[6])
      lists[3].add(@songs[7])
      assert((lists[2] - lists[3]).empty?, 'Case should not matter for the difference')
    end

    def test_exclusiveTo
      lists = [SongList.new(@songs[0], @songs[1]),
               SongList.new(@songs[1], @songs[2])]

      exclusiveTo_msg = 'The songs to add are those that are in the given list but not in this list'
      assert(lists[0].exclusiveTo(lists[1]).first.eql?(@songs[2]), exclusiveTo_msg)
      assert(lists[1].exclusiveTo(lists[0]).first.eql?(@songs[0]), exclusiveTo_msg)
    end

    def test_inspect
      lists = [SongList.new, SongList.new(@songs[0], @songs[1])]

      # There should be a working inspect method.
      assert_nothing_raised do
        lists.each { |list| list.inspect }
      end
    end

    def test_clear
      list = SongList.new
      @songs.each { |song| list << song }

      assert(list.clear.empty?, "List should be empty after being cleared")
    end
  end
end
