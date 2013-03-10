# -*- coding: utf-8 -*-

require 'highline/import'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controller for a set of songs in a CSV file.
  class CsvCLI

    # Public: Creates a CLI.
    #
    # controller - A Controller for a CSV set of songs.
    # ui         - General user interface to use.
    def initialize(controller, ui)
      @controller = controller
      @ui = ui
    end

    # Asks for a String naming a column separator and returns it.
    #
    # s - Service for which this is a CLI.
    def column_separator(s)
      ask("Column separator for #{s.user} #{s.name} #{s.type}? ")
    end
  end
end
