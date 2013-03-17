# -*- coding: utf-8 -*-

require_relative '../song_set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controller for a service.
  class ServiceController

    attr_reader :user, :name, :type, :set, :ui
    attr_accessor :action, :strict_search, :interactive, :search_result,
    :songs_to_add, :added_songs

    # Public: Create a service controller.
    #
    # user   - A String naming the user name or the file path for the
    #          service.
    # name   - A String naming the name of the service.
    # type   - A String naming the service type.
    # ui     - General user interface to use.
    def initialize(user, name, type, ui)
      @user = user
      @name = name
      @type = type
      @action = action
      @ui = ui

      @search_result = SongSet.new
      @songs_to_add = SongSet.new
    end

    # Public: Returns true if this service controller is equal to the
    # compared service controller. This method and hash are defined so
    # that Sets of service controllers behave reasonably, i.e. service
    # controller for the same user/file, name and type should be
    # treated as equal.
    #
    # other - Service controller that this song is compared with.
    def eql?(other)
      user.casecmp(other.user) == 0 &&
        name.casecmp(other.name) == 0 &&
        type.casecmp(other.type) == 0
    end

    # Public: Makes a hash value for this object and returns it. This
    # method and eql? are defined so that Sets of service controllers
    # behave reasonably, i.e. service controller for the same
    # user/file, name and type should be treated as equal.
    def hash
      [user, name, type].join('').downcase.hash
    end
  end
end
