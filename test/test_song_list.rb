# -*- coding: utf-8 -*-

require 'test/unit'
require_relative '../lib/sync-songs/song_list.rb'

# Public: Classes for syncing lists of songs
module SyncSongs
  # Private: Unit test for the class SongList
  class TestSongList < Test::Unit::TestCase

    # Run before each test
    def setup
      @list1 = SongList.new
      @list2 = SongList.new
    end

    def test_simple
      init_msg = "Song lists should initialize"
      assert_not_nil(@list1, init_msg)
      assert_not_nil(@list2, init_msg)
    end

    def test_add
      add_msg = "A song list should not manipulate its content"
      song1 = Song.new("Artist1", "Title1")
      song2 = Song.new("Artist2", "Title2")
      song3 = Song.new("Artist1", "Title2")
      @list1.add(song1)
      assert_equal(song1, @list1.first, add_msg)
      @list2.add(song2).add(song3)
      assert_equal(song2, @list2.first, add_msg)
    end

    def test_difference
      song1 = Song.new("Artist1", "Title1")
      song2 = Song.new("Artist2", "Title2")
      song3 = Song.new("Artist1", "Title2")
      song4 = Song.new("Artist2", "Title1")
      song5 = Song.new("Artist1", "Title1")
      song6 = Song.new("Artist2", "Title2")
      song7 = Song.new("artist", "Title")
      song8 = Song.new("Artist", "title")

      list3 = SongList.new
      list4 = SongList.new
      list3.add(song1).add(song2).add(song3)
      list4.add(song3).add(song1).add(song2)
      assert(list3.difference(list4).empty?, "No difference between sets with the same members that has been added in different order")
      assert(list3.-(list4).empty?, "Aliases should be equal")

      list3.add(song1)
      list4.add(song3)
      assert(list3.difference(list4).empty?, "There are no duplicate entries")

      list3.add(song7)
      list4.add(song8)
      puts list3.to_a
      puts list4.to_a
      assert(list3.difference(list4).empty?, "Case should not matter for the difference")
    end
  end
end
