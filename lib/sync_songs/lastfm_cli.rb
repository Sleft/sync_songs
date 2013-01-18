# -*- coding: utf-8 -*-

require 'highline/import'
require_relative 'lastfm_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: A CLI for Last.fm sets of songs.
  class LastfmCLI
    attr_reader :set

    def initialize
      @set = LastfmSet.new(ask('Last.fm API key? ') { |q| q.echo = false },
                           ask('Last.fm API secret? ') { |q| q.echo = false },
                           ask('Last.fm username? '))
    end
  end
end
