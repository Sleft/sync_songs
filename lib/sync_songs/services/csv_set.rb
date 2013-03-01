# -*- coding: utf-8 -*-

require 'csv'
require_relative '../song_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: A set of songs in a CSV file.
  class CSVSet < SongSet
    # Public: Hash of types of services associated with what they
    # support.
    SERVICES = {library: :rw}

    # Public: Constructs a CSV set.
    #
    # file_path - File to use.
    # col_sep   - The column separator.
    def initialize(file_path, col_sep = ',')
      super()
      @file_path = file_path
      @col_sep = col_sep # FIXME implement support for

      # FIXME Create file if it does not exist?
    end

    # Public: Get the user's library from the CSV file.
    #
    # Returns self.
    def library
      CSV.foreach(@file_path, {:col_sep => @col_sep}) { |row| add(Song.new(*row)) }
      self
    end

    # Public: Add the songs in the given set to the user's library in
    # the CSV file.
    #
    # other - A SongSet to add from.
    #
    # Returns an array of the songs that was added.
    def addToLibrary(other)
      CSV.open(@file_path, 'w', {:col_sep => @col_sep}) do |csv|
        other.each do |s|
          csv << [s.name, s.artist, s.album, s.duration, s.id]
        end
      end

      other.to_a
    end

    # Public: Searches for the given song set in the CSV file. Since
    # any song can be stored in a CSV file no search has to
    # made. Therefore the SongSet to search for is simply returned.
    #
    # other         - SongSet to search for.
    # strict_search - True if search should be strict (default: true).
    def search(other, strict_search = true)
      other
    end
  end
end
