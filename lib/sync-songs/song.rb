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

    # Public: Returns true if this song is equal to the compared song.
    #
    # other - Song that this song is compared with.
    def eql?(other)
      title.casecmp(other.title) == 0 &&
        artist.casecmp(other.artist) == 0
    end

    # Public: Returns true if this song includes the other song.
    #
    # other - Song that this song is compared with.
    def include?(other)
      title.downcase.include?(other.title.downcase) &&
        artist.downcase.include?(other.artist.downcase)
    end

    # Public: Returns true if this song is similar to the compared
    # song.
    #
    # other - Song that this song is compared with.
    def similar?(other)
      # Since the other song is more probably a song from a search in
      # a big database with many versions of every song the following
      # test order should perform better.
      other.include?(self) || include?(other)
    end

    # Public: Makes a hash value for this object and returns it.
    def hash
      "#{title}#{artist}".downcase.hash
    end

    # Public: Returns the song formatted as a string.
    def to_s
      "#{title} - #{artist}"
    end

    # Public: Returns the song formatted as appropriately for use in a
    # search query.
    def to_search_term
      "#{title.downcase} #{artist.downcase}"
    end
  end
end
