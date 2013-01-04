# -*- coding: utf-8 -*-

require 'test/unit'
require_relative '../../lib/sync-songs/song_list.rb'

# Public: Classes for syncing lists of songs
module SyncSongs
  # Private: Unit test for the class SongList
  class TestSongList < Test::Unit::TestCase

    # Run before each test
    def setup
      @list1 = SongList.new
      @list2 = SongList.new
      @song1 = Song.new("Artist1", "Title1")
      @song2 = Song.new(" Artist2", "Title2  ")
      @song3 = Song.new("Artist1   ", "      Title2")
      @song4 = Song.new("Artist2", "Title1")
      @song5 = Song.new("Artist1", "Title1")
      @song6 = Song.new("Artist2", "Title2")
      @song7 = Song.new("artist", "Title")
      @song8 = Song.new("Artist", "title")

      @list1.add(@song1)
      @list2 << @song1  # Test alias too
    end

    def test_simple
      init_msg = "Song lists should initialize"
      assert_not_nil(@list1, init_msg)
      assert_not_nil(@list2, init_msg)
    end

    def test_add
      add_msg = "A song list should not manipulate its content"
      assert_equal(@song1, @list1.first, add_msg)
      assert_equal(@song1, @list2.first, add_msg)
      assert(@list1.member?(@song1), add_msg)
      assert(@list2.member?(@song1), add_msg)
    end

    def test_difference
      diff_eql_msg = "There is no difference between sets with the same members"
      # @list1 = {@song1}
      # @list2 = {@song1}
      assert(@list1.difference(@list2).empty?, diff_eql_msg)
      assert(@list2.difference(@list1).empty?, diff_eql_msg)

      @list1.add(@song2)        # @list1 = {@song1, @song2}
      @list2.add(@song3)        # @list2 = {@song1, @song3}
      assert(!(@list1 - @list2).member?(@song1), "The difference is not the shared element")

      diff_msg = "The difference is the non-shared element in the receiver"
      assert((@list1 - @list2).member?(@song2), diff_msg)
      assert((@list2 - @list1).member?(@song3), diff_msg)
      @list1.add(@song3)        # @list1 = {@song1, @song2, @song3}
      assert((@list1 - @list2).member?(@song2), diff_msg)
      assert((@list2 - @list1).empty?, diff_msg)

      list3 = SongList.new
      list4 = SongList.new
      list3 << @song1 << @song2 << @song3
      list4 << @song3 << @song1 << @song2
      assert((list3 - list4).empty?, "There is no difference between sets with the same members that has been added in different order")
      assert((list3 - list4).empty?, "The alias - for difference should work")

      list3.add(@song1)
      list4.add(@song3)
      assert((list3 - list4).empty?, "There are no duplicate entries")

      list3.add(@song7)
      list4.add(@song8)
      assert((list3 - list4).empty?, "Case should not matter for the difference")
    end

    def test_inspect
      # There should be a working inspect method
      assert_nothing_raised do
        @list1.inspect
        @list2.inspect
        list5 = SongList.new
        list5.inspect
      end
    end
  end
end
