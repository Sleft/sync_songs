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

    # Public: Asks for a String naming a Grooveshark password and
    # returns it.
    def password
      ask("Grooveshark password for #{@controller.user}? ") { |q| q.echo = false }
    end
  end
end
