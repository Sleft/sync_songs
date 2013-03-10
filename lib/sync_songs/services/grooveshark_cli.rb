# -*- coding: utf-8 -*-

require 'highline/import'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Command-line interface for a Grooveshark set of songs.
  class GroovesharkCLI

    # Public: Creates a CLI.
    #
    # controller - A Controller for a Grooveshark set of songs.
    # ui         - General user interface to use.
    def initialize(controller, ui)
      @controller = controller
      @ui = ui
    end

    # Asks for a String naming a Grooveshark password and returns it.
    #
    # s - Service for which this is a CLI.
    def password(s)
      ask("Grooveshark password for #{s.user}? ") { |q| q.echo = false }
    end
  end
end
