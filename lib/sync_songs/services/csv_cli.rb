# -*- coding: utf-8 -*-

require 'highline/import'
require 'launchy'
require_relative 'csv_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: A command-line interface for a set of songs in a CSV file.
  class CsvCLI

    # Public: Creates a CLI.
    #
    # service - Service for which this is a user interface.
    # ui      - General user interface to use.
    def initialize(service, ui)
      @service = service
      @ui = ui
      file_path = @service.user.to_s
      col_sep = ask("Column separator for #{service.user} #{service.name} #{service.type}? ")
      @service.set = if col_sep.empty?
                       CsvSet.new(file_path)
                     else
                       CsvSet.new(file_path, col_sep)  
                     end
    end

    # Public: UI wrapper for library library.
    def library
      @service.set.library
    end

    # Public: UI wrapper for library addToLibrary.
    #
    # other - A SongSet to add from.
    #
    # Raises?
    def addToLoved(other)
      @service.set.addToLoved(other)
    end

    # Public: Ask for preferences of options for adding songs.
    def addPreferences
      @ui.strict_search(@service)
      @ui.interactive(@service)
    end
  end
end
