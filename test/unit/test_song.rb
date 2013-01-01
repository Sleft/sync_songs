# -*- coding: utf-8 -*-

require 'test/unit'
require_relative '../../lib/sync-songs/song'

# Public: Classes for syncing lists of songs
module SyncSongs
  # Private: Unit test for the class Song
  class TestSong < Test::Unit::TestCase
    # Run before each test
    def setup
      @song1 = Song.new("  Artist1", "Title1  ")
      @song2 = Song.new(" Artist2 ", " Title2 ")
      @song3 = Song.new("   Artist1 ", "  Title2    ")
      @song4 = Song.new("Artist2", "Title1")
      @song5 = Song.new("Artist1", " Title1   ")
      @song6 = Song.new("Artist2", "  Title2 ")
      @song7 = Song.new("     artist", "Title")
      @song8 = Song.new("Artist     ", "      title ")
    end

    def test_simple
      init_msg = "Songs should initialize"
      assert_not_nil(@song1, init_msg)
      assert_not_nil(@song2, init_msg)

      assert_raise(ArgumentError) { song9 = Song.new("", "Title") }
      assert_raise(ArgumentError) { song10 = Song.new("Artist", "") }
      assert_raise(ArgumentError) { song11 = Song.new("   ", "    ") }
    end

    def test_strip
      lead_trail_ws = /(^\s+)|(\s+$)/
      strip_msg = "Songs should be stripped from leading and trailing whitespace"
      assert_nil(lead_trail_ws.match(@song1.artist), strip_msg)
      assert_nil(lead_trail_ws.match(@song1.title), strip_msg)
      assert_nil(lead_trail_ws.match(@song2.artist), strip_msg)
      assert_nil(lead_trail_ws.match(@song2.title), strip_msg)
    end

    def test_getters
      getter_msg = "Getters should return an unchanged value"
      assert_equal(@song1.artist, "Artist1", getter_msg)
      assert_equal(@song2.artist, "Artist2", getter_msg)
      assert_not_equal(@song1.artist, "Artist2", getter_msg)
      assert_not_equal(@song2.artist, "Artist1", getter_msg)

      assert_equal(@song1.title, "Title1", getter_msg)
      assert_equal(@song2.title, "Title2", getter_msg)
      assert_not_equal(@song1.title, "Title2", getter_msg)
      assert_not_equal(@song2.title, "Title1", getter_msg)
    end

    def test_song_equal
      identity_msg = "Songs should be self-identical"
      assert(@song1.eql?(@song1), identity_msg)
      assert(@song2.eql?(@song2), identity_msg)

      assert(!@song1.eql?(@song2) && !@song2.eql?(@song1),
             "Non-equality for songs is symmetrical")

      both_fields_equality_msg = "Both fields affect equality"
      assert(!@song2.eql?(@song3), both_fields_equality_msg)
      assert(!@song3.eql?(@song4), both_fields_equality_msg)
      assert(!@song4.eql?(@song5), both_fields_equality_msg)
      assert(!@song5.eql?(@song6), both_fields_equality_msg)

      assert(@song7.eql?(@song8), "Case should not matter for equality")

      sanity_msg = "Assumptions about test data should be correct"
      assert_not_equal(@song2, @song3, sanity_msg)
      assert_not_equal(@song3, @song4, sanity_msg)
      assert_not_equal(@song4, @song5, sanity_msg)
      assert_not_equal(@song5, @song6, sanity_msg)
    end

    def test_to_s
      assert_equal(@song1.to_s, "Artist1 - Title1", "to_s is in conventional form")
      assert(@song2.to_s.is_a?(String), "to_s returns a String")
    end
  end
end
