# -*- coding: utf-8 -*-

require_relative '../../../lib/sync_songs/song'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Internal: Data for tests. DO NOT CHANGE unless you want to change
  # the meaning of many tests.
  module SampleData
    def setupTestSongs
      @songs = [Song.new('Name1  '    , '  Artist1'),   # 0
                Song.new(' Name2 '    , ' Artist2 '),   # 1
                Song.new('  Name2    ', '   Artist1 '), # 2
                Song.new('Name1'      , 'Artist2'),     # 3
                Song.new(' Name1   '  , 'Artist1'),     # 4
                Song.new('  Name2 '   , 'Artist2'),     # 5
                Song.new('Name'       , '     artist'), # 6
                Song.new('      name ', 'Artist     '), # 7
                Song.new('Some name', 'An Artist',      # 8
                         'The Album', 330, 'qwerty')]
    end
  end
end
