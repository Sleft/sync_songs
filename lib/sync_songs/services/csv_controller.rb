# -*- coding: utf-8 -*-

require_relative 'csv_cli'
require_relative 'csv_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controller for a set of songs in a CSV file.
  class CsvController < ServiceController

    # Public: Hash of types of services associated with what they
    # support.
    SERVICES = {library: :rw}

    # Public: Creates a controller.
    #
    # user   - A String naming the user name or the file path for the
    #          service.
    # name   - A String naming the name of the service.
    # type   - A String naming the service type.
    # ui     - General user interface to use.
    def initialize(user, name, type, ui)
      super(user, name, type, ui)

      file_path = @user.to_s
      @service_ui = CsvCLI.new(self, @ui)

      col_sep = @service_ui.column_separator
      @set = if col_sep.empty?
               CsvSet.new(file_path)
             else
               CsvSet.new(file_path, col_sep)
             end
    end

    # Public: Wrapper for CSV library.
    def library
      @set.library
    rescue ArgumentError, Errno::EACCES, Errno::ENOENT => e
      @ui.fail("Failed to get #{type} from #{name} #{user}\n"\
               "#{e.message.strip}", 1, e)
    end

    # Public: Wrapper for adding to CSV library.
    #
    # other - A SongSet to add from.
    def addToLibrary(other)
      @set.addToLibrary(other)
    rescue Errno::EACCES, Errno::ENOENT => e
      @ui.fail("Failed to add #{type} to #{name} #{user}\n"\
               "#{e.message.strip}", 1, e)
    end

    # Public: Wrapper for searching for the given song in the CSV song
    # set.
    #
    # other         - SongSet to search for.
    # strict_search - True if search should be strict (default:
    #                 true). Has no effect. Exist for compatibility.
    def search(other, strict_search = true)
      @set.search(other, strict_search = true)
    end


    # Public: Ask for preferences of options for adding songs.
    def addPreferences
      @ui.interactive(self)
    end

    # Public: Ask for preferences of options for searching for songs.
    def searchPreferences
      @ui.strict_search(self)
    end
  end
end
