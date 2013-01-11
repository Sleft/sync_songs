# -*- coding: utf-8 -*-

# Public: Classes for syncing lists of songs
module SyncSongs
  # Public: Stores a song.
  class Song
    # Public: Returns the title of the song and the artist performing the
    # song.
    attr_reader :title, :artist

    # Public: Constructs a song. Leading and trailing whitespace is
    # removed as it has no semantic significance for songs.
    #
    # title  - The title of the song
    # artist - The artist performing the song
    #
    # Raises ArgumentError if the artist or the title is empty.
    def initialize(title, artist)
      @title  = title.strip
      @artist = artist.strip

      if @title.empty? || @artist.empty?
        fail ArgumentError, 'Songs must have a non-empty title and artist'
      end
    end

    # Public: Compares this song to another song and returns true if
    # they are equal. Two songs are equal if they have the same title
    # and are by the same artist independently of the letter case of
    # either.
    #
    # other - Song that this song is compared with.
    #
    # Returns true if this song is equal to the compared song.
    def eql?(other)
      title.casecmp(other.title) == 0 &&
        artist.casecmp(other.artist) == 0
    end

    # Public: Makes a hash value for this object and returns it.
    def hash
      "#{title}#{artist}".downcase.hash
    end

    # Public: Returns the song formatted as a string.
    def to_s
      "#{title} - #{artist}"
    end
  end
end
