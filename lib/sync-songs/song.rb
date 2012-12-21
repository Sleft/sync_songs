# -*- coding: utf-8 -*-

module SyncSongs
  ##
  # Stores a song
  class Song
    attr_reader :artist, :title

    ##
    # Constructs a song of the given artist and title.
    def initialize(artist, title)
      @artist = artist
      @title  = title
    end

    ##
    # Two songs are equal if they have the same title and are by the
    # same independently of the case of either.
    def eql?(song)
      title.casecmp(song.title) == 0 and
        artist.casecmp(song.artist) == 0
    end

    ##
    # Returns the song conventionally formatted.
    def to_s
      "#{artist} - #{title}"
    end
  end
end
