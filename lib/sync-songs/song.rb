# -*- coding: utf-8 -*-

# Public: Classes for syncing lists of songs.
module SyncSongs
  # Public: Stores a song.
  class Song
    include Comparable

    # Public: Returns the name of the song and the artist performing the
    # song.
    attr_reader :name, :artist

    # Public: Constructs a song. Leading and trailing whitespace is
    # removed as it has no semantic significance for songs.
    #
    # name   - The name of the song.
    # artist - The artist performing the song.
    #
    # Raises ArgumentError if the artist or the name is empty.
    def initialize(name, artist)
      @name   = name.strip
      @artist = artist.strip

      if @name.empty? || @artist.empty?
        fail ArgumentError, 'Songs must have a non-empty name and artist'
      end
    end

    # Public: Comparison -- returns -1 if other song is greater than,
    # 0 if other song equal to and +1 if other song is less than this
    # song.
    #
    # other - Song that this song is compared with.
    def <=>(other)
      comparison = name.casecmp(other.name)

      comparison == 0 ? artist.casecmp(other.artist) : comparison
    end

    # Public: Returns true if this song is equal to the compared song.
    #
    # other - Song that this song is compared with.
    def eql?(other)
      (self <=> other) == 0
    end

    # Public: Returns true if this song includes the other song.
    #
    # other - Song that this song is compared with.
    def include?(other)
      name.downcase.include?(other.name.downcase) &&
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
      "#{name}#{artist}".downcase.hash
    end

    # Public: Returns the song formatted as a string.
    def to_s
      "#{name} - #{artist}"
    end

    # Public: Returns the song formatted as appropriately for use in a
    # search query.
    def to_search_term
      "#{name.downcase} #{artist.downcase}"
    end
  end
end
