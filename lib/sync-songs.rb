# -*- coding: utf-8 -*-

module SyncSongs
  # Temporary delegation to favorite sync
  require './sync-fav-songs.rb'
  include SyncFavSongs
end
