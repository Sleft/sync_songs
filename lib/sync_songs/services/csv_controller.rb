# -*- coding: utf-8 -*-

require_relative 'csv_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controller for a set of songs in a CSV file.
  class CsvController

    # Public: Creates a controller.
    #
    # service - Service for which this is a controller.
    # ui      - General user interface to use.
    def initialize(service, ui)
      @service = service
      @ui = ui
      file_path = @service.user.to_s
      @service_ui = CsvCLI.new(self, @ui)

      col_sep = @service_ui.column_separator
      @service.set = if col_sep.empty?
                       CsvSet.new(file_path)
                     else
                       CsvSet.new(file_path, col_sep)
                     end
    end

    # Public: Wrapper for CSV library.
    def library
      @service.set.library
    end

    # Public: Wrapper for adding to CSV library.
    #
    # other - A SongSet to add from.
    def addToLoved(other)
      @service.set.addToLoved(other)
    end

    # Public: Ask for preferences of options for adding songs.
    def addPreferences
      @ui.interactive(@service)
    end

    # Public: Ask for preferences of options for searching for songs.
    def searchPreferences
      @ui.strict_search(@service)
    end
  end
end
