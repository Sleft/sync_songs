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
    end

    def diff
      @directions = @services.collect { |i| Struct::DirectionInput.new(i.shift.to_sym, i.shift.to_sym, :r) }
      checkSupport
      @services.each { |s, _| initializeUI(s) }
      # getData
      # showDifference
    end

    def sync
      @directions = @ui.directions(@services)
      checkSupport
      @services.each { |s, _| initializeUI(s) }
      # getData
      # addData(interactive = true)
    end

    # input_services.each { |s, _| initializeUI(s) }

    # 

    # @sets.each { |s| s.getFavorites }

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

    # Internal: Try to initialize the UI for the given service. Sends
    # a message to the UI if it fails.
    #
    # service - A String naming the service.
    def initializeUI(service)
      service_ui = "#{service.capitalize}#{@ui.class.name.split('::').last}"
      begin                     # AVOID EVAL
        @sets << (eval "#{service_ui}.new").set
      rescue NameError => e
        @ui.fail("Failed to initialize #{service_ui}.", e)
      end
    end
  end
end
