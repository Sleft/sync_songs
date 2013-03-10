# -*- coding: utf-8 -*-

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
    end
  end
end
