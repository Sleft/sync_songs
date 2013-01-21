# -*- coding: utf-8 -*-

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controls syncing.
  class Controller

    # Public: Constructs a controller.
    #
    # ui             - The user interface to use.
    # input_services - A hash of services associated with types,
    #                  e.g. {'lastfm' => 'favorites', 'grooveshark' =>
    #                  'favorites'} (default = nil).
    def initialize(ui, input_services)
      @ui = ui
      @input_services = input_services
      ui.fail('You must supply at least two distinct services.') if @input_services.size < 2
      @services = Set.new
    end

    def diff
      @ui.verboseMessage("Preparing to diff song sets")
      @input_services.each { |i| @services << Struct::Service.new(i.shift.to_sym, i.shift.to_sym, :r) }
      getData
      # showDifference
    end

    def sync
      @ui.verboseMessage("Preparing to sync song sets")
      @directions = @ui.directions(@input_services)
      directionsToServices
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
      threads = []

      checkSupport
      @services.each { |s| initializeUI(s) }

      @services.each do |service|
        threads << Thread.new(service) do |s|
          @ui.verboseMessage("Downloading from #{s.type} from #{s.name}...")
          s.set.send(s.type) # Need to delegate this to UI so that
          # lastfm's version can be rescued if it
          # throws an exception
          @ui.verboseMessage("Finished downloading #{s.type} from #{s.name}")
        end
      end

      threads.each { |t| t.join }
    end

    def addData(strict_search = true, interactive = true)
      @services.each { |s| s.ui.addPreferences(s) }

      # For each in direction(service1, service2, direction)
      #   if < or =
      #    search and write from service2 to service1
      #   if > or =
      #    search and write from service1 to service2

      # @services.each do |s|
      #   s.set.send("#{s.type}Candidates")
    end

    # Internal: Try to initialize the UI for the given service and get
    # a reference to its song set which is stored in the Service
    # Struct.
    #
    # service - A Struct::Service.
    def initializeUI(service)
      service_ui = "#{service.name.capitalize}#{@ui.class.name.split('::').last}"
      begin
        service.ui = SyncSongs.const_get(service_ui).new(@ui)
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
