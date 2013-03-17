# -*- coding: utf-8 -*-

require 'test/unit'
require_relative '../../../lib/sync_songs/services/service_controller'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Internal: Unit test for the class ServiceController.
  class TestLastfmSet < Test::Unit::TestCase

    def test_simple
      ca = [ServiceController.new('user', 'name', 'type', 'ui'),
           ServiceController.new('USER', 'NAME', 'TYPE', 'UI')]

      eql_msg = 'Service controllers with the same user, name and '\
      'type are equal'
      assert(ca[0].eql?(ca[1]))
      assert(ca[1].eql?(ca[0]))

      cs = Set.new(ca)

      assert_equal(cs.size, 1, 'There cannot be several service '\
                   'controllers with the same user, name and type '\
                   'in a Set are equalService controller')
    end
  end
end
