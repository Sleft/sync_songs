# -*- coding: utf-8 -*-

# Public: Classes for syncing lists of songs
module SyncSongs
  # Public: Stores a song.
  class Song
    # Public: Returns the title of the song, the artist performing the
    # song and the album the song is on respectively.
    attr_reader :title, :artist, :album

    # Public: Constructs a song. Leading and trailing whitespace is
    # removed as it has no semantic significance for songs.
    #
    # title  - The title of the song
    # artist - The artist performing the song
    # album  - The album the song is on
    #
    # Raises ArgumentError if the artist or the title is empty.
    def initialize(title, artist, album)
      @title  = title.strip
      @artist = artist.strip
      @album  = album.strip

      if @title.empty? or @artist.empty?
        raise ArgumentError, "Songs must have a non-empty title and artist"
      end
    end

    # Public: Compares this song to another song and returns true if
    # they are equal. Two songs are equal if they have the same title
    # and are by the same artist independently of the letter case of
    # either. It is assumed that album is not significant for
    # favorites, e.g. if a certain song by a certain artist is a
    # favorite it is a favorite independently of which album it is
    # found on.
    #
    # compared_song - Song that this song is compared with.
    #
    # Returns true if this song is equal to the compared
    # song.
    def eql?(compared_song)
      title.casecmp(compared_song.title) == 0 and
        artist.casecmp(compared_song.artist) == 0
    end

    # Public: Makes a hash value for this object and returns it. It is
    # assumed that album is not significant for favorites. This is why
    # the album is not included in the hash.
    def hash
      (title + artist).downcase.hash
    end

    # Public: Returns the song conventionally formatted as a string.
    def to_s
      s = "#{title} - #{artist}"
      s << " - #{album}" unless album.empty?
      s
    end
  end
end
