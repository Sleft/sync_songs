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
    # separator - The username of the user to authenticate (default:
    #             nil).
    def initialize(file_path, separator = nil)
      super()
      self.file_path = file_path
      self.separator = separator # FIXME implement support for

      # FIXME Create file if it does not exist?
    end

    # Public: Get the user's library from the CSV file.
    #
    # Returns self.
    def library
      CSV.foreach(file_path) { |row| add(Song.new(*row)) }
      self
    end

    # Public: Add the songs in the given set to the user's library in
    # the CSV file.
    #
    # other - A SongSet to add from.
    #
    # Returns an array of the songs that was added.
    def addToFavorites(other)
      other.each do |s|
        CSV.open(file_path, 'w') do |csv|
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
      result
    end
  end
end
