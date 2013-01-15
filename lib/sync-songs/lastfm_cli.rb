# -*- coding: utf-8 -*-

require 'highline/import'
require_relative 'lastfm_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: A CLI for Last.fm sets of songs.
  class LastfmCLI
    def initialize
      api_key = ask('Last.fm API key? ') { |q| q.echo = false }
      api_secret = ask('Last.fm API secret? ') { |q| q.echo = false }
      @set = LastfmSet.new(api_key, api_secret)
    end
  end
end
