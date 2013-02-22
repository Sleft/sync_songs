# -*- coding: utf-8 -*-

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Stores a song.
  class Song
    include Comparable

    # Public: Returns the name of the song and the artist performing the
    # song.
    attr_reader :name, :artist, :album, :duration, :id

    # Public: Constructs a song. Leading and trailing whitespace is
    # removed as it has no semantic significance for songs.
    #
    # name   - The name of the song.
    # artist - The artist performing the song.
    #
    # Raises ArgumentError if the artist or the name is empty.
    def initialize(name, artist, album = nil, duration = nil, id = nil)
      @name     = name.strip
      @artist   = artist.strip
      @album    = album.strip if album
      @duration = Time.at(duration).utc.strftime('%H:%M:%S') unless duration.zero? if duration
      @id       = id

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
      comp = name.casecmp(other.name)

      if comp == 0
        comp = artist.casecmp(other.artist)
      end

      if comp == 0 && album && other.album
        comp = album.casecmp(other.album)
      end

      # if comp == 0
      #   if album && !other.album
      #     comp = 1
      #   elsif !album && other.album
      #     comp = -1
      #   end
      # end

      comp
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
      [artist, name, album].compact.join('').downcase.hash
    end

    # Public: Returns the song formatted as a string.
    def to_s
      [artist, name, album, duration].compact.join(' - ')
    end

    # Public: Returns the song formatted as appropriately for use in a
    # search query.
    def to_search_term
      # When including album search on Last.fm barely finds anything.
      [artist, name].compact.join(' ')
    end
  end
end
