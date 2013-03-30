# -*- coding: utf-8 -*-

require_relative 'lastfm_cli'
require_relative 'lastfm_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controller for a Last.fm set of songs.
  class LastfmController < ServiceController

    # Public: Hash of types of services associated with what they
    # support.
    SERVICES = {loved: :rw}

    # Public: Creates a controller.
    #
    # user   - A String naming the user name or the file path for the
    #          service.
    # name   - A String naming the name of the service.
    # type   - A String naming the service type.
    # ui     - General user interface to use.
    def initialize(user, name, type, ui)
      super(user, name, type, ui)

      @service_ui = LastfmCLI.new(self, @ui)
      @set = LastfmSet.new(@service_ui.apiKey,
                           @service_ui.apiSecret,
                           @user)
    end

    # Public: Wrapper for Last.fm loved songs.
    def loved
      @set.loved
    rescue ArgumentError, EOFError, Lastfm::ApiError, SocketError, Timeout::Error => e
      @ui.fail("Failed to get #{type} from #{name} #{user}\n"\
               "#{e.message.strip}", 1, e)
    end

    # Public: Wrapper for adding to Last.fm loved songs. Authorizes
    # the session before adding songs.
    #
    # other - A SongSet to add from.
    def addToLoved(other)
      # TODO Store token somewhere instead and only call URL if there is no
      # stored token.
      authorized = nil

      @mutex.synchronize do
        authorized = @service_ui.authorize(@set.authorizeURL)
      end

      if authorized
        begin
          @set.authorizeSession
          @set.addToLoved(other)
        rescue Lastfm::ApiError, SocketError => e
        @ui.fail("Failed to add #{type} to #{name} #{user}\n"\
                 "#{e.message.strip}", 1, e)
        end
      end
    end

    # Public: Wrapper for searching for the given song set at Last.fm.
    #
    # other         - SongSet to search for.
    # limit         - Maximum limit for search results (default:
    #                 @set.limit).
    # strict_search - True if search should be strict (default: true).
    #
    # Returns a SongSet.
    def search(other, limit = @set.limit, strict_search = true)
      @set.search(other, limit, strict_search)
    rescue ArgumentError, EOFError, Errno::EINVAL, SocketError,
      Timeout::Error  => e
      @ui.fail("Failed to search #{name} #{user}\n#{e.message.strip}", 1, e)
    end
  end
end
