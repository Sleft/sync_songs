# -*- coding: utf-8 -*-

require 'test/unit'
require_relative '../../lib/sync_songs/song_set'
require_relative 'sample_data/sample_data'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Private: Unit test for the class SongSet.
  class TestSongSet < Test::Unit::TestCase
    include SampleData

    def setup
      setupTestSongs
    end

    def test_size
      set = SongSet.new
      set << @songs[0]

      size_msg = 'Should return set\'s size'
      assert(set.size == 1, size_msg)
      assert(set.length == 1, size_msg)
    end

    def test_simple
      sets = [SongSet.new, SongSet.new]

      init_msg = 'Song sets should initialize'
      assert_not_nil(sets[0], init_msg)
      assert_not_nil(sets[1], init_msg)
    end

    def test_add
      # add is used by the constructor of SongSet
      sets = [SongSet.new(@songs[0]), SongSet.new(@songs[0])]

      add_msg = 'A song set should not manipulate its content'
      assert_equal(@songs[0], sets[0].first, add_msg)
      assert_equal(@songs[0], sets[1].first, add_msg)
      assert(sets[0].member?(@songs[0]), add_msg)
      assert(sets[1].member?(@songs[0]), add_msg)
    end

    def test_add?
      addq_msg = 'add? works as expected'
      set = SongSet.new
      assert_equal(set.add?(@songs[0]), set, addq_msg)
      assert_equal(set.add?(@songs[0]), nil, addq_msg)
    end

    def test_difference
      sets = [SongSet.new(@songs[0]), SongSet.new(@songs[0])]

      diff_eql_msg = 'There is no difference between sets with the same members'
      assert(sets[0].difference(sets[1]).empty?, diff_eql_msg)
      assert(sets[1].difference(sets[0]).empty?, diff_eql_msg)

      sets[0].add(@songs[1])  # sets[0] = {@songs[0], @songs[1]}
      sets[1].add(@songs[2])  # sets[1] = {@songs[0], @songs[2]}
      assert(!(sets[0] - sets[1]).member?(@songs[0]), 'The difference is not the shared element')

      diff_msg = 'The difference is the non-shared element in the receiver'
      assert((sets[0] - sets[1]).member?(@songs[1]), diff_msg)
      assert((sets[1] - sets[0]).member?(@songs[2]), diff_msg)
      sets[0].add(@songs[2]) # sets[0] = {@songs[0], @songs[1], @songs[2]}
      assert((sets[0] - sets[1]).member?(@songs[1]), diff_msg)
      assert((sets[1] - sets[0]).empty?, diff_msg)

      sets[2] = SongSet.new(@songs[0], @songs[1], @songs[2])
      sets[3] = SongSet.new(@songs[2], @songs[0], @songs[1])
      assert((sets[2] - sets[3]).empty?, 'There is no difference between sets with the same members that has been added in different order')
      assert((sets[2] - sets[3]).empty?, 'The alias - for difference should work')

      sets[2].add(@songs[0])
      sets[3].add(@songs[2])
      assert((sets[2] - sets[3]).empty?, 'There are no duplicate entries')

      sets[2].add(@songs[6])
      sets[3].add(@songs[7])
      assert((sets[2] - sets[3]).empty?, 'Case should not matter for the difference')
    end

    def test_empty?
      empty_msg = 'empty? works as expected'
      set = SongSet.new()
      assert(set.empty?, empty_msg)
      set << @songs[0]
      assert(!set.empty?, empty_msg)
    end

    def test_exclusiveTo
      sets = [SongSet.new(@songs[0], @songs[1]),
               SongSet.new(@songs[1], @songs[2])]

      exclusiveTo_msg = 'The songs to add are those that are in the given set but not in this set'
      assert(sets[0].exclusiveTo(sets[1]).first.eql?(@songs[2]), exclusiveTo_msg)
      assert(sets[1].exclusiveTo(sets[0]).first.eql?(@songs[0]), exclusiveTo_msg)
    end

    def test_inspect
      sets = [SongSet.new, SongSet.new(@songs[0], @songs[1])]

      # There should be a working inspect method.
      assert_nothing_raised do
        sets.each { |set| set.inspect }
      end
    end

    def test_clear
      set = SongSet.new
      @songs.each { |song| set << song }

      assert(set.clear.empty?, 'Set should be empty after being cleared')
    end

    def test_to_a
      to_a_msg = 'to_a works as expected'
      set = SongSet.new(@songs[0], @songs[1])
      set = set.to_a
      assert_equal(set.class, Array, to_a_msg)
      assert_equal(set[0], @songs[0], to_a_msg)
    end
  end
end
