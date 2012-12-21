# -*- coding: utf-8 -*-

# Public: Classes for syncing lists of songs
module SyncSongs
  # Public: Stores a song.
  class Song
    # Public: Returns the artist performing the song and the title of
    # the song respectively.
    attr_reader :artist, :title

    # Public: Constructs a song of the given artist and title.
    #
    # artist - The artist performing the song
    # title  - The title of the song
    def initialize(artist, title)
      @artist = artist
      @title  = title
    end


    # Public: Compares this song to another song and returns true if
    # they are equal. Two songs are equal if they have the same title
    # and are by the same artist independently of the letter case of
    # either.
    #
    # compared_song - Song that this song is compared with.
    #
    # Returns true if this song is equal to the compared
    # song.
    def eql?(compared_song)
      title.casecmp(compared_song.title) == 0 and
        artist.casecmp(compared_song.artist) == 0
    end

    # Public: Makes a hash value for this object and returns it.
    def hash
      (artist + title).downcase.hash
    end

    # Public: Returns the song conventionally formatted as a string.
    def to_s
      "#{artist} - #{title}"
    end
  end
end
