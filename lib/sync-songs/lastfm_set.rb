# -*- coding: utf-8 -*-

require 'lastfm'
require 'launchy'
require_relative 'song_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: A set of Grooveshark songs.
  class LastfmSet < SongSet

    # Public: Constructs a Last.fm set by logging in to
    # Last.fm with the specified user.
    #
    # username - The username of the user to authenticate.
    # password - The password of the user to authenticate.
    def initialize(api_key, api_secret)
      super()
      @api_key = api_key
      @lastfm = Lastfm.new(api_key, api_secret)
    end

    # Public: Get the user's loved songs from Last.fm.
    #
    # username - The username of the user to authenticate.
    # limit    - The maximum number of favorites to get.
    #
    # Raises Lastfm::ApiError if the username is invalid.
    def getLoved(username, limit)
      @lastfm.user.get_loved_tracks(user: username,
                                    api_key: @api_key,
                                    limit: limit).each do |s|
        add(Song.new(s['name'], s['artist']['name']))
      end
    end

    # Public: Add the songs in the given set to the given user's
    # loved songs on Last.fm.
    #
    # other - An array of songs to add from.
    #
    # Raises Lastfm::ApiError if the username if the Last.fm token has
    #   not been authorized or if the song is not recognized.
    #
    # Returns an array of the songs that was added.
    def addToLoved(other)
      authorize

      songsAdded = []

      other.each { |song| songsAdded << song if @lastfm.track.love(track: song.name, artist: song.artist) }

      songsAdded
    end

    # Public: Searches for loved candidates at Last.fm.
    #
    # other         - SongSet to search for.
    # strict_search - True if search should be strict (default: true).
    #
    # Returns an array of loved candidates.
    def getLovedCandidates(other, limit, strict_search = true)
      candidates = []

      # Search for songs that are not already favorites and add them
      # as candidates if they are sufficiently similar.
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
    # to Last.fm) asking the user to authorize and open a page in the
    # web browser in which the user can do this.
    def authorize
      # Store token somewhere instead and only call URL if there is no
      # stored token.
      token = @lastfm.auth.get_token
      Launchy.open("http://www.last.fm/api/auth/?api_key=#@api_key&token=#{token}")
      print 'A page asking for authorization of this tool with Last.fm should be open in your web browser. You need to approve it before proceeding. Continue? (y/n) '
      exit unless gets.strip.casecmp('y') == 0

      @lastfm.session = @lastfm.auth.get_session(token: token)['key']
    end
  end
end
