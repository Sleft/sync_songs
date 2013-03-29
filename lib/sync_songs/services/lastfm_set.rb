# -*- coding: utf-8 -*-

require 'lastfm'
require_relative '../song_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: A set of Grooveshark songs.
  class LastfmSet < SongSet

    # Public: Default limit for API calls.
    DEFAULT_LIMIT = 1_000_000

    attr_reader :limit

    # Public: Creates a Last.fm set by logging in to Last.fm with the
    # specified user.
    #
    # api_key    - Last.fm API key.
    # api_secret - Last.fm secret for API key.
    # username   - The username of the Last.fm user.
    # limit      - The maximum number of results from calls (default:
    #              DEFAULT_LIMIT).
    def initialize(api_key, api_secret, username = nil, limit = DEFAULT_LIMIT)
      super()
      @api_key = api_key
      @username = username
      @lastfm = Lastfm.new(api_key, api_secret)
      @limit = limit
    end

    # Public: Get the user's loved songs from Last.fm. The reason this
    # takes ages to complete is that it first has to search tracks to
    # find them and then get info for each found track to be able to
    # get the album title.
    #
    # username - The username of the user to authenticate (default:
    #            @username).
    #
    # limit    - The maximum number of favorites to get (default:
    #            @limit).
    #
    # Raises ArgumentError from xml-simple some reason.
    # Raises Lastfm::ApiError if the username is invalid or there is a
    #   temporary error.
    # Raises SocketError if the connection fails.
    # Raises Timeout::Error if the connection fails.
    #
    # Returns self.
    def loved(username = @username, limit = @limit)
      lov = @lastfm.user.get_loved_tracks(user: username,
                                          api_key: @api_key,
                                          limit: limit)

      if lov                                # Remove if API is fixed.
        lov = [lov] unless lov.is_a?(Array) # Remove if API is fixed.

        lov.each do |l|

          # Get metadata for loved track.
          s = @lastfm.track.get_info(track: l['name'],
                                     artist: l['artist']['name'])

          add(Song.new(s['name'], s['artist']['name'],
                       # Not all Last.fm tracks belong to an album.
                       s.key?('album') ? s['album']['title'] : nil,
                       Float(s['duration']) / 1_000, s['id']))
        end
      end

      self
    end

    alias_method :favorites, :loved

    # Public: Add the songs in the given set to the given user's loved
    # songs on Last.fm. This method requires an authorized session
    # which is gotten by getting the user to authorize via the url
    # given by authorizeURL and then running authorize.
    #
    # other - A SongSet to add from.
    #
    # Raises Lastfm::ApiError if the Last.fm token has not been
    #   authorized or if the song is not recognized.
    # Raises SocketError if the network connection fails.
    #
    # Returns an array of the songs that was added.
    def addToLoved(other)
      songsAdded = []

      if @lastfm.session
        other.each do |s|
          songsAdded << s if @lastfm.track.love(track: s.name,
                                                artist: s.artist)
        end
      end

      songsAdded
    end

    alias_method :addToFavorites, :addToLoved

    # Public: Searches for the given song set at Last.fm. The reason
    # this takes ages to complete is that it first has to search
    # tracks to find them and then get info for each found track to be
    # able to get the album title.
    #
    # other         - SongSet to search for.
    # limit         - Maximum limit for search results (default:
    #                 @limit).
    # strict_search - True if search should be strict (default: true).
    #
    # Raises ArgumentError from xml-simple some reason.
    # Raises EOFError when end of file is reached.
    # Raises Errno::EINVAL if the network connection fails.
    # Raises SocketError if the network connection fails.
    # Raises Timeout::Error if the network connection fails.
    #
    # Returns a SongSet.
    def search(other, limit = @limit, strict_search = true)
      result = SongSet.new

      # Search for songs and return them if they are sufficiently
      # similar.
      other.each do |song|
        # The optional parameter artist for track.search does not seem
        # to work so it is not used.
        search_result = @lastfm.track.search(track: song.to_search_term,
                                      limit: limit)['results']['trackmatches']['track'].compact

        found_songs = []

        search_result.each do |r|
          found_songs << @lastfm.track.get_info(track: r['name'],
                                                artist: r['artist'])
        end

        unless found_songs.empty?
          found_songs.each do |f|
            other = Song.new(f['name'], f['artist']['name'],
                             # Not all Last.fm tracks belong to an album.
                             f.key?('album') ? f['album']['title'] : nil,
                             Float(f['duration']) / 1_000, f['id'])
            if strict_search
              next unless song.eql?(other)
            else
              next unless song.similar?(other)
            end
            result << other
          end
        end
      end
      result
    end

    # Public: Return an URL for authorizing a Last.fm session.
    #
    # Raises SocketError if the network connection fails.
    def authorizeURL
      @token = @lastfm.auth.get_token
      "http://www.last.fm/api/auth/?api_key=#@api_key&token=#@token"
    end


    # Public: Authorize a Last.fm session (needed for certain calls to
    # Last.fm, such as addToLoved). Get the user to authorize via the
    # URL returned by authorizeURL before calling this method.
    #
    # Raises SocketError if the network connection fails.
    def authorizeSession
      if @token
        @lastfm.session = @lastfm.auth.get_session(token: @token)['key']
      else
        fail StandardError, "Before calling #{__method__} a token "\
        'must be authorized, e.g. by calling authorizeURL and '\
        'getting the user to authorize via that URL'
      end
    end
  end
end
