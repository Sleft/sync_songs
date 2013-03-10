# -*- coding: utf-8 -*-

require 'highline/import'
require 'launchy'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Command-line interface for a Last.fm set of songs.
  class LastfmCLI

    # Public: Creates a CLI.
    #
    # controller - A Controller for a Last.fm set of songs.
    # ui         - General user interface to use.
    def initialize(controller, ui)
      @controller = controller
      @ui = ui
    end

    # Public: Asks for a String naming a Last.fm API key and returns
    # it.
    #
    # s - Service for which this is a CLI.
    def apiKey(s)
      ask("Last.fm API key for #{s.user} #{s.name} #{s.type}? ") { |q| q.echo = false }
    end

    # Public: Asks for a String naming a Last.fm API key and returns
    # it.
    #
    # s - Service for which this is a CLI.
    def apiSecret(s)
      ask("Last.fm API secret for #{s.user} #{s.name} #{s.type}? ") { |q| q.echo = false }
    end

    # Public: Asks the user to authorize this tool with Last.fm and
    # wait for input.
    #
    # url - A String naming a URL to use for authorization.
    def authorize(url)
      Launchy.open(url)
      ask('A page asking for authorization with Last.fm should be open in your web browser. You need to approve it before proceeding. Continue? (y/n) ')
    end
  end
end
