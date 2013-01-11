# -*- coding: utf-8 -*-

require_relative '../../../lib/sync-songs/song'

# Public: Classes for syncing lists of songs
module SyncSongs
  # Internal: Data for tests
  module SampleData
    def setupTestSongs
      @songs = [Song.new('Title1  '    , '  Artist1'),   # 0
                Song.new(' Title2 '    , ' Artist2 '),   # 1
                Song.new('  Title2    ', '   Artist1 '), # 2
                Song.new('Title1'      , 'Artist2'),     # 3
                Song.new(' Title1   '  , 'Artist1'),     # 4
                Song.new('  Title2 '   , 'Artist2'),     # 5
                Song.new('Title'       , '     artist'), # 6
                Song.new('      title ', 'Artist     ')] # 7
    end
  end
end
