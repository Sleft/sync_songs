# -*- coding: utf-8 -*-

require 'highline/import'
require_relative 'lastfm_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: A command-line interface for Last.fm sets of songs.
  class LastfmCLI
    attr_reader :set

    # Public: Construct a CLI.
    #
    # ui - General user interface to use.
    def initialize(ui)
      @ui = ui
      @set = LastfmSet.new(ask('Last.fm API key? ') { |q| q.echo = false },
                           ask('Last.fm API secret? ') { |q| q.echo = false },
                           ask('Last.fm username? '))
    end

    def addPreferences(service)
      @ui.strict_search(service)
      @ui.interactive(service)
    end
  end
end
