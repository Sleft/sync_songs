# -*- coding: utf-8 -*-

require 'lastfm'
require 'highline/import'       # Should be in UI?
require 'launchy'               # Should be in UI?
require_relative 'song_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: A set of Grooveshark songs.
  class LastfmSet < SongSet
    # Public: Hash of types of services associated with what they support.
    SERVICES = {loved: :rw, favorites: :rw}
    # Public: Default limit for API calls.
    DEFAULT_LIMIT = 1_000_000

    # Public: Constructs a Last.fm set by logging in to
    # Last.fm with the specified user.
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

    # Public: Get the user's loved songs from Last.fm.
    #
    # username - The username of the user to authenticate (default:
    #            @username).
    # 
    # limit    - The maximum number of favorites to get (default:
    #            @limit).
    #
    # Raises Lastfm::ApiError if the username is invalid.
    #
    # Returns self.
    def loved(username = @username, limit = @limit)
      @lastfm.user.get_loved_tracks(user: username,
                                    api_key: @api_key,
                                    limit: limit).each do |s|
        add(Song.new(s['name'], s['artist']['name']))
      end
      self
    end

    alias_method :favorites, :loved

    # Public: Add the songs in the given set to the given user's
    # loved songs on Last.fm.
    #
    # other - An array of songs to add from.
    #
    # Raises Lastfm::ApiError if the Last.fm token has not been
    #   authorized or if the song is not recognized.
    #
    # Returns an array of the songs that was added.
    def addToLoved(other)
      authorize
      
      songsAdded = []

      if @lastfm.session
        other.each { |song| songsAdded << song if @lastfm.track.love(track: song.name, artist: song.artist) }
      end

      songsAdded
    end

    alias_method :addToFavorites, :addToLoved

    # Public: Searches for the given song set at Last.fm.
    #
    #
    # other         - SongSet to search for.
    # limit         - Maximum limit for search results (default:
    #                 @limit).
    # strict_search - True if search should be strict (default: true).
    #
    # Returns an array of loved candidates.
    def search(other, limit = @limit, strict_search = true)
      candidates = []           # Should be a set

      # Search for songs that are not already in this set and return
      # them if they are sufficiently similar.
      exclusiveTo(other).each do |song|
        # The optional parameter artist for track.search does not seem
        # to work so it is not used.
        found_songs = @lastfm.track.search(track: song.to_search_term,
                                      limit: limit)['results']['trackmatches']['track'].compact

        unless found_songs.empty?
          found_songs.each do |found_song|
            other = Song.new(found_song['name'], found_song['artist'])
            if strict_search
              next unless song.eql?(other)
            else
              next unless song.similar?(other)
            end
            candidates << other
          end
        end
      end
      candidates
    end

    private

    # Internal: Authorize a Last.fm session (needed for certain calls
    # to Last.fm). Sould be in UI?
    def authorize
      # Store token somewhere instead and only call URL if there is no
      # stored token.
      token = @lastfm.auth.get_token

      Launchy.open("http://www.last.fm/api/auth/?api_key=#@api_key&token=#{token}")
      exit unless ask('A page asking for authorization of this tool with Last.fm should be open in your web browser. You need to approve it before proceeding. Continue? (y/n) ').casecmp('y') == 0

      @lastfm.session = @lastfm.auth.get_session(token: token)['key']
    end
  end
end
