# -*- coding: utf-8 -*-

require 'test/unit'
require_relative 'sample_data/sample_data'

# Public: Classes for syncing lists of songs
module SyncSongs
  # Internal: Unit test for the class Song
  class TestSong < Test::Unit::TestCase
    include SampleData

    # Run before each test
    def setup
      setupTestSongs
    end

    def test_simple
      init_msg = 'Songs should initialize'
      assert_not_nil(@songs[0], init_msg)
      assert_not_nil(@songs[1], init_msg)

      assert_raise(ArgumentError) { @songs << Song.new(''       , 'Title') }
      assert_raise(ArgumentError) { @songs << Song.new('Artist' , '') }
      assert_raise(ArgumentError) { @songs << Song.new('   '    , '    ') }
    end

    def test_strip
      lead_trail_ws = /(^\s+)|(\s+$)/
      strip_msg = 'Songs should be stripped from leading and trailing whitespace'
      @songs.each do |song|
        assert_nil(lead_trail_ws.match(song.title), strip_msg)
        assert_nil(lead_trail_ws.match(song.artist), strip_msg)
      end
    end

    def test_getters
      getter_msg = 'Getters should return an unchanged value'
      assert_equal(@songs[0].artist, 'Artist1', getter_msg)
      assert_equal(@songs[1].artist, 'Artist2', getter_msg)
      assert_not_equal(@songs[0].artist, 'Artist2', getter_msg)
      assert_not_equal(@songs[1].artist, 'Artist1', getter_msg)

      assert_equal(@songs[0].title, 'Title1', getter_msg)
      assert_equal(@songs[1].title, 'Title2', getter_msg)
      assert_not_equal(@songs[0].title, 'Title2', getter_msg)
      assert_not_equal(@songs[1].title, 'Title1', getter_msg)
    end

    def test_song_equal
      identity_msg = 'Songs should be self-identical'
      assert(@songs[0].eql?(@songs[0]), identity_msg)
      assert(@songs[1].eql?(@songs[1]), identity_msg)

      assert(!@songs[0].eql?(@songs[1]) && !@songs[1].eql?(@songs[0]),
             'Non-equality for songs is symmetrical')

      both_fields_equality_msg = 'Only the fields title and artist affect equality'
      assert(!@songs[1].eql?(@songs[2]), both_fields_equality_msg)
      assert(!@songs[2].eql?(@songs[3]), both_fields_equality_msg)
      assert(!@songs[3].eql?(@songs[4]), both_fields_equality_msg)
      assert(!@songs[4].eql?(@songs[5]), both_fields_equality_msg)

      spaces_not_significant_msg = 'Spaces are not significant for equality'
      assert(@songs[0].eql?(@songs[4]), spaces_not_significant_msg)
      assert(@songs[1].eql?(@songs[5]), spaces_not_significant_msg)

      assert(@songs[6].eql?(@songs[7]), 'Case should not matter for equality')

      sanity_msg = 'Assumptions about test data should be correct'
      assert_not_equal(@songs[1], @songs[2], sanity_msg)
      assert_not_equal(@songs[2], @songs[3], sanity_msg)
      assert_not_equal(@songs[3], @songs[4], sanity_msg)
      assert_not_equal(@songs[4], @songs[5], sanity_msg)
    end

    def test_to_s
      assert(@songs[1].to_s.is_a?(String), 'to_s returns a String')
      assert_equal(@songs[0].to_s, 'Title1 - Artist1', 'to_s is in correct form')
    end
  end
end
