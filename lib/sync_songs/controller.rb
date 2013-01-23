# -*- coding: utf-8 -*-

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controls syncing and diffing of sets of songs.
  class Controller

    # Public: Constructs a controller.
    #
    # ui             - The user interface to use.
    # input_services - A hash of services associated with types,
    #                  e.g. {'lastfm' => 'favorites', 'grooveshark' =>
    #                  'favorites'}.
    def initialize(ui, input_services)
      @ui = ui
      @input_services = input_services
      ui.fail('You must supply at least two distinct services.') if @input_services.size < 2
      @services = Set.new
    end

    # Public: Diffs the song sets of the input services.
    def diff
      @ui.verboseMessage("Preparing to diff song sets")

      @input_services.each { |i| @services << Struct::Service.new(i.shift.to_sym, i.shift.to_sym, :r) }
      checkSupport

      directionsToServices
      @services.each { |s| initializeServiceUI(s) }

      getData
      # showDifference
    end

    # Public: Syncs the song sets of the input services.
    def sync
      @ui.verboseMessage("Preparing to sync song sets")

      @directions = @ui.directions(@input_services)
      checkSupport

      directionsToServices
      @services.each { |s| initializeServiceUI(s) }

      addPreferences

      getData
      addData
    end

    # Public: Returns a hash of services associated with their
    # supported types associated with supported action.
    #
    # Example:
    #   Controller.supportedServices =>
    #     {:grooveshark=>{:favorites=>:rw}, :lastfm=>{:loved=>:rw,
    #     :favorites=>:rw}}
    def self.supportedServices
      services = {}

      # Get the classes that extends SongSet.
      classes = ObjectSpace.each_object(Class).select { |klass| klass < SongSet }

      # Associate the class name with its supported services.
      classes.each do |klass|
        # Only accept classes that ends with 'Set'.
        class_name = klass.name.split('::').last.sub(/Set\Z/, '').downcase
        services[class_name.to_sym] = klass::SERVICES unless class_name.empty?
      end

      services
    end

    private

    # Internal: Checks if the action and the type and for the input
    # service are supported, e.g. if reading (action) from favorites
    # (type) at Grooveshark (service) is supported. Fails via UI if
    # something is not supported.
    def checkSupport
      supported_services = Controller.supportedServices

      @services.each do |i|
        fail_msg = " is not supported."

        # Is the service supported?
        fail_msg = "#{i.name}#{fail_msg}"
        @ui.fail(fail_msg) unless supported_services.key?(i.name)

        # Is the type supported?
        supported_types = supported_services[i.name]
        fail_msg = "#{i.type} for #{fail_msg}"
        @ui.fail(fail_msg) unless supported_types.key?(i.type)

        # Is the action supported?
        fail_msg = "#{i.action} to #{fail_msg}"
        supported_action = supported_types[i.type]
        @ui.fail(fail_msg) unless supported_action == i.action || supported_action == :rw
      end
    end

    # Internal: Gets the data for each service.
    def getData
      @ui.message('Downloading data. This might take a while.')
      getCurrentData
      getSearchResults
    end

    # Internal: Gets the current data from each service, e.g. the
    # current favorites from Grooveshark and Last.fm. The data is not
    # returned but stored in the set of the each service.
    def getCurrentData
      threads = []

      @services.each do |service|
        threads << Thread.new(service) do |s|
          @ui.verboseMessage("Downloading #{s.type} from #{s.name}...")
          s.set.send(s.type) # Need to delegate this to UI so that
          # lastfm's version can be rescued if it
          # throws an exception
          @ui.verboseMessage("Finished downloading #{s.type} from #{s.name}")
        end
      end

      threads.each { |t| t.join }
    end

    # Internal: Gets the search result from the services that should
    # be synced to. The data is stored in the search_result of each
    # Struct::Service.
    def getSearchResults
      threads = []

      @directions.each do |direction|
        threads << Thread.new(direction) do |d|
          if d.direction == :'<' || d.direction == :'='
            d.services.first.search_result = search(d.services.first, d.services.last)
          end
        end
        threads << Thread.new(direction) do |d|
          if d.direction == :'>' || d.direction == :'='
            d.services.last.search_result = search(d.services.last, d.services.first)
          end
        end
      end

      threads.each { |t| t.join }
    end

    # Internal: Searches for songs that are exclusive to service2 at
    # service1, e.g. gets the search result on Grooveshark of the
    # songs that are exclusive to Last.fm.
    #
    # service1 - Service to search.
    # service2 - Service with songs to search for.
    #
    # Returns the result as a SongSet.
    def search(service1, service2)
      @ui.verboseMessage("Searching #{service1.name}...")
      result = service1.set.send(:search, service2.set, service1.strict_search)
      @ui.verboseMessage("Finished searching #{service1.name}")

      result
    end

    # Internal: Ask for preferences of options for adding songs.
    def addPreferences
      @directions.each do |d|
        if d.direction == :'<' || d.direction == :'='
          d.services.first.ui.addPreferences
        end
        if d.direction == :'>' || d.direction == :'='
          d.services.last.ui.addPreferences
        end
      end
    end

    # Internal: Adds the data to be synced to each service.
    def addData
      @directions.each do |d|
        d.services.each do |s|
          if s.interactive      # Add songs interactively
            interactiveAdd(s)
          else                  # or add them all without asking.
            s.songs_to_add = s.search_results
          end
        end
      end

      # Threaded add each service.songs_to_add
    end

    # Internal: For each found missing song in a service, ask whether
    # to add it to that service.
    def interactiveAdd(service)
      service.search_result.each { |song| service.songs_to_add << song if @ui.addSong?(song, service) }
    end

    # Internal: Try to initialize the UI for the given service and get
    # a reference to its song set which is then stored in the
    # Struct::Service.
    #
    # service - A Struct::Service.
    def initializeServiceUI(service)
      service_ui = "#{service.name.capitalize}#{@ui.class.name.split('::').last}"
      begin
        service.ui = SyncSongs.const_get(service_ui).new(service, @ui)
        service.set = service.ui.set
      rescue NameError => e
        @ui.fail("Failed to initialize #{service_ui}.", e)
      end
    end

    # Internal: Translate directions to an array of Struct::Service.
    def directionsToServices
      @directions.each do |d|
        support = []

        case d.direction
        when :'<' then support << :w << :r
        when :'=' then support << :rw << :rw
        when :'>' then support << :r << :w
        end

        d.services.each do |s|
          s.action = support.shift
          @services << s
        end
      end
    end
  end
end
