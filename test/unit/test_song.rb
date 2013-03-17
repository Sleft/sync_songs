# -*- coding: utf-8 -*-

require 'test/unit'
require_relative 'sample_data/sample_data'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Internal: Unit test for the class Song.
  class TestSong < Test::Unit::TestCase
    include SampleData

    def setup
      setupTestSongs
    end

    def test_simple
      init_msg = 'Songs should initialize'
      assert_not_nil(@songs[0], init_msg)
      assert_not_nil(@songs[1], init_msg)

      assert_raise(ArgumentError) { @songs << Song.new(''       , 'Name') }
      assert_raise(ArgumentError) { @songs << Song.new('Artist' , '') }
      assert_raise(ArgumentError) { @songs << Song.new('   '    , '    ') }
    end

    def test_strip
      lead_trail_ws = /(^\s+)|(\s+$)/
      strip_msg = 'Songs should be stripped from leading and '\
      'trailing whitespace'
      @songs.each do |song|
        assert_nil(lead_trail_ws.match(song.name), strip_msg)
        assert_nil(lead_trail_ws.match(song.artist), strip_msg)
      end
    end

    def test_getters
      getter_msg = 'Getters should return an unchanged value'
      assert_equal(@songs[0].artist, 'Artist1', getter_msg)
      assert_equal(@songs[1].artist, 'Artist2', getter_msg)
      assert_not_equal(@songs[0].artist, 'Artist2', getter_msg)
      assert_not_equal(@songs[1].artist, 'Artist1', getter_msg)

      assert_equal(@songs[0].name, 'Name1', getter_msg)
      assert_equal(@songs[1].name, 'Name2', getter_msg)
      assert_not_equal(@songs[0].name, 'Name2', getter_msg)
      assert_not_equal(@songs[1].name, 'Name1', getter_msg)
    end

    def test_spaceship
      spaceship_msg = 'The spaceship works as expected'
      assert_equal(@songs[0] <=> @songs[1], -1, spaceship_msg)
      assert_equal(@songs[1] <=> @songs[0], 1, spaceship_msg)
      assert_equal(@songs[1] <=> @songs[2], 1, spaceship_msg)
      assert_equal(@songs[4] <=> @songs[3], -1, spaceship_msg)
      assert_equal(@songs[0] <=> @songs[4], 0, spaceship_msg)
      assert_equal(@songs[1] <=> @songs[5], 0, spaceship_msg)
      assert_equal(@songs[6] <=> @songs[7], 0, spaceship_msg)
    end

    def test_comparison_operators
      comparison_msg = 'Comparison operators works as expected'
      assert(@songs[0] < @songs[1], comparison_msg)
      assert(@songs[1] > @songs[0], comparison_msg)
      assert(@songs[1] > @songs[2], comparison_msg)
      assert(@songs[0] < @songs[3], comparison_msg)
      assert(@songs[4] <= @songs[5], comparison_msg)
      assert(@songs[6] <= @songs[7], comparison_msg)
      assert(@songs[6] == @songs[7], comparison_msg)
    end

    def test_eql?
      identity_msg = 'Songs should be self-identical'
      assert(@songs[0].eql?(@songs[0]), identity_msg)
      assert(@songs[1].eql?(@songs[1]), identity_msg)

      assert(!@songs[0].eql?(@songs[1]) && !@songs[1].eql?(@songs[0]),
             'Non-equality for songs is symmetrical')

      both_fields_equality_msg = 'Only the fields name and artist '\
      'affect equality'
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

    def test_include?
      identical_msg = 'Identical songs includes each others'
      assert(@songs[0].include?(@songs[4]), identical_msg)
      assert(@songs[4].include?(@songs[0]), identical_msg)
      assert(@songs[1].include?(@songs[5]), identical_msg)
      assert(@songs[5].include?(@songs[1]), identical_msg)

      case_msg = 'include? works as expected and is not sensitive to case'
      assert(@songs[2].include?(@songs[6]), case_msg)
      assert(@songs[2].include?(@songs[7]), case_msg)
    end

    def test_similar?
      similar_msg = 'similar? is like reflexive include'
      assert(@songs[0].similar?(@songs[6]), similar_msg)
      assert(@songs[6].similar?(@songs[0]), similar_msg)
      assert(@songs[3].similar?(@songs[7]), similar_msg)
      assert(@songs[7].similar?(@songs[3]), similar_msg)
    end

    def to_search_term
      assert_equal(@songs[0].to_search_term, 'name1 artist1',
                   'Search term is in correct form')
    end

    def test_to_s
      assert_equal(@songs[0].to_s, 'Artist1 - Name1',
                   'String is in correct form')
    end
  end
end
