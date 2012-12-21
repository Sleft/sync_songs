# -*- coding: utf-8 -*-

# Public: Classes for syncing lists of songs
module SyncSongs
  # Temporary delegation to favorite sync
  require './sync-fav-songs.rb'
  include SyncFavSongs
end
