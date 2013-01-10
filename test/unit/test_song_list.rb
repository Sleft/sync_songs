# -*- coding: utf-8 -*-

require 'test/unit'
require_relative '../../lib/sync-songs/song_list'
require_relative 'sample_data/sample_data'

# Public: Classes for syncing lists of songs
module SyncSongs
  # Private: Unit test for the class SongList
  class TestSongList < Test::Unit::TestCase
    include SampleData

    # Run before each test
    def setup
      setupTestSongs

      @lists = [SongList.new, SongList.new, SongList.new, SongList.new]

      @lists[0].add(@songs[0])
      @lists[1] << @songs[0]  # Test alias too
    end

    def test_size
      size_msg = 'Should return list\'s size'
      assert(@lists[0].size == 1, size_msg)
      assert(@lists[1].length == 1, size_msg)
    end

    def test_simple
      init_msg = 'Song lists should initialize'
      assert_not_nil(@lists[0], init_msg)
      assert_not_nil(@lists[1], init_msg)
    end

    def test_add
      add_msg = 'A song list should not manipulate its content'
      assert_equal(@songs[0], @lists[0].first, add_msg)
      assert_equal(@songs[0], @lists[1].first, add_msg)
      assert(@lists[0].member?(@songs[0]), add_msg)
      assert(@lists[1].member?(@songs[0]), add_msg)
    end

    def test_difference
      diff_eql_msg = 'There is no difference between sets with the same members'
      # @lists[0] = {@songs[0]}
      # @lists[1] = {@songs[0]}
      assert(@lists[0].difference(@lists[1]).empty?, diff_eql_msg)
      assert(@lists[1].difference(@lists[0]).empty?, diff_eql_msg)

      @lists[0].add(@songs[1])  # @lists[0] = {@songs[0], @songs[1]}
      @lists[1].add(@songs[2])  # @lists[1] = {@songs[0], @songs[2]}
      assert(!(@lists[0] - @lists[1]).member?(@songs[0]), 'The difference is not the shared element')

      diff_msg = 'The difference is the non-shared element in the receiver'
      assert((@lists[0] - @lists[1]).member?(@songs[1]), diff_msg)
      assert((@lists[1] - @lists[0]).member?(@songs[2]), diff_msg)
      @lists[0].add(@songs[2]) # @lists[0] = {@songs[0], @songs[1], @songs[2]}
      assert((@lists[0] - @lists[1]).member?(@songs[1]), diff_msg)
      assert((@lists[1] - @lists[0]).empty?, diff_msg)

      @lists[2] = SongList.new
      @lists[3] = SongList.new
      @lists[2] << @songs[0] << @songs[1] << @songs[2]
      @lists[3] << @songs[2] << @songs[0] << @songs[1]
      assert((@lists[2] - @lists[3]).empty?, 'There is no difference between sets with the same members that has been added in different order')
      assert((@lists[2] - @lists[3]).empty?, 'The alias - for difference should work')

      @lists[2].add(@songs[0])
      @lists[3].add(@songs[2])
      assert((@lists[2] - @lists[3]).empty?, 'There are no duplicate entries')

      @lists[2].add(@songs[6])
      @lists[3].add(@songs[7])

      assert((@lists[2] - @lists[3]).empty?, 'Case nor album should matter for the difference')
    end

    def test_songsToAdd
      songsToAdd_msg = 'The songs to add are those that are in the given list but not in this list'
      @lists[2] << @songs[0] << @songs[1]
      @lists[3] << @songs[1] << @songs[2]
      assert(@lists[2].songsToAdd(@lists[3]).first.eql?(@songs[2]), songsToAdd_msg)
      assert(@lists[3].songsToAdd(@lists[2]).first.eql?(@songs[0]), songsToAdd_msg)
    end

    def test_inspect
      # There should be a working inspect method
      assert_nothing_raised do
        @lists[0].inspect
        @lists[1].inspect
        @lists[4] = SongList.new
        @lists[4].inspect
      end
    end

    def test_clear
      list = SongList.new
      @songs.each { |song| list << song }
      assert(list.clear.empty?, "List should be empty after being cleared")
    end
  end
end
