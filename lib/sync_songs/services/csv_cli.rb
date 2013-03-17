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
    def column_separator
      ask("Column separator for #{@controller.user} "\
          "#{@controller.name} "\
          "#{@controller.type}? ") { |q| q.default = ',' }
    end
  end
end
