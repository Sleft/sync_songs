# -*- coding: utf-8 -*-

require_relative '../../../lib/sync-songs/song'

# Public: Classes for syncing lists of songs
module SyncSongs
  # Internal: Data for tests
  module SampleData
    def setupTestSongs
      @songs = [Song.new("Title1  "    , "  Artist1"   , " Album1 "), # 0
                Song.new(" Title2 "    , " Artist2 "   , "Album2  "), # 1
                Song.new("  Title2    ", "   Artist1 " , "  Album1"), # 2
                Song.new("Title1"      , "Artist2"     , "Album2"),   # 3
                Song.new(" Title1   "  , "Artist1"     , " Album5"),  # 4
                Song.new("  Title2 "   , "Artist2"     , "Album6 "),  # 5
                Song.new("Title"       , "     artist" , " Album7 "), # 6
                Song.new("      title ", "Artist     " , "Album8")]   # 7
    end
  end
end
