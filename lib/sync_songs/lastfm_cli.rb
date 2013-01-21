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
    # service - Service for which this is a user interface.
    # ui      - General user interface to use.
    def initialize(service, ui)
      @service = service
      @ui = ui
      @set = LastfmSet.new(ask('Last.fm API key? ') { |q| q.echo = false },
                           ask('Last.fm API secret? ') { |q| q.echo = false },
                           ask('Last.fm username? '))
    end

    def addPreferences
      @ui.strict_search(@service)
      @ui.interactive(@service)
    end
  end
end
