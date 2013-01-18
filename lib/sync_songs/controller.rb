# -*- coding: utf-8 -*-

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controls syncing.
  class Controller

    # Public: Constructs a controller.
    #
    # ui       - The user interface to use.
    # services - A hash of services associated with types,
    #            e.g. {'lastfm' => 'favorites', 'grooveshark' =>
    #            'favorites'} (default = nil).
    def initialize(ui, services)
      @ui = ui
      @services = services
      ui.fail('You must supply at least two distinct services.') if @services.size < 2
      @sets = {}
    end

    def diff
      @ui.verboseMessage("Preparing to diff song sets")
      @directions = @services.collect { |i| Struct::DirectionInput.new(i.shift.to_sym, i.shift.to_sym, :r) }
      getData
      # showDifference
    end

    def sync
      @ui.verboseMessage("Preparing to sync song sets")
      @directions = @ui.directions(@services)
      getData
      # addData(interactive = true)
    end

    # For each service initialize
    # Threads: For each service get data
    #          Save compare data
    # Ask for each missing song if it shall be synced (y/n)
    # Threads (if both directions): Set data


    # Public: Returns a hash of services associated with types of
    # services and their support direction.
    def self.supportedServices
      services = {}

      # Get the classes that extends SongSet.
      classes = ObjectSpace.each_object(Class).select { |klass| klass < SongSet }

      # Associate the class name with it services.
      classes.each do |klass|
        class_name = klass.name.split('::').last.sub(/Set\Z/, '').downcase
        # Only accept classes that ends with 'Set'.
        services[class_name.to_sym] = klass::SERVICES unless class_name.empty?
      end

      services
    end

    private

    # Internal: Checks if the input service, type and action are
    # supported, e.g. if reading (action) from favorites (type) at
    # Grooveshark (service) is supported. Fails via UI if something is
    # not supported.
    def checkSupport
      supported_services = Controller.supportedServices

      @directions.each do |i|
        fail_msg = " is not supported."

        # Is the service supported?
        fail_msg = "#{i.service}#{fail_msg}"
        @ui.fail(fail_msg) unless supported_services.key?(i.service)

        # Is the type supported?
        supported_types = supported_services[i.service]
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
      threads = []

      checkSupport
      @services.each { |s, _| initializeUI(s) }

      @sets.each do |n, s|
        threads << Thread.new(n, s) do |name, set|
          @ui.verboseMessage("Downloading from #{name}...")
          set.favorites # Need to delegate this to UI so that lastfm's
                        # version can be rescued if it throws an
                        # exception
          @ui.verboseMessage("Finished downloading from #{name}")
        end
      end

      threads.each { |t| t.join }
    end

    # Internal: Try to initialize the UI for the given service and get
    # a reference to its song set which is stored in hash associated
    # with the service name.
    #
    # service - A String naming the service.
    def initializeUI(service)
      service_ui = "#{service.capitalize}#{@ui.class.name.split('::').last}"
      begin                     # AVOID EVAL
        @sets[service.to_sym] = (eval "#{service_ui}.new").set
      rescue NameError => e
        @ui.fail("Failed to initialize #{service_ui}.", e)
      end
    end
  end
end
