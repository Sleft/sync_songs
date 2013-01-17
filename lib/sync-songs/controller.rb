# -*- coding: utf-8 -*-

require 'set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controls syncing.
  class Controller

    # Public: Constructs a controller.
    #
    # action   - A Symbol naming the action to perform.
    # types    - A hash of services associated with types.
    # ui       - The user interface to use.
    def initialize(action, services, ui)
      @action = action
      @services = services
      @ui = ui
      ui.fail('You must supply at least two distinct services.') if @services.size < 2

      @directions = ui.directions(@services) if @action == :sync

      # Check if service exists
      supported_services = Controller.services

      if @action == :sync
        @directions.each do |type, support|
          if supported_services.key?(type)
            unless supported_services[type].find { |k, v| {k => v} == support } ||
                (supported_services[type] && support == :rw)
              ui.fail("#{support.values.join(', ')} to #{support.keys.join(', ')} for #{type} is not supported.")
            end
          else
            ui.fail("#{type} is not supported.")
          end
          
        end
      end

      required_methods_defined?

      @services.each { |s, _| initializeUI(s) }

      @sets = []

      @sets.each { |s| p s.getFavorites }


      # For each service initialize
      # Threads: For each service get data
      #          Save compare data
      # Ask for each missing song if it shall be synced (y/n)
      # Threads (if both directions): Set data


    end

    # Public: Returns a hash of services associated with types of
    # services and their support direction.
    def self.services
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

    # Internal: Raises NoMethodError if a required method for the
    # services in question is not defined. It is better to fail sooner
    # than later.
    def required_methods_defined?
      # @required_methods = { get: ["get#{@type.capitalize}".to_sym,
      #                             "get#{@type[0..-2].capitalize}Candidates".to_sym],
      #   set: "addTo#{@type.capitalize}".to_sym }

      # För varje service kolla om läsa ifall riktning är från eller båda
      @services.each do |service, type|
        if @action == :sync

        elsif @action == :diff
          # Check if there are read methods for all
          required_methods = ["get#{type.capitalize}".to_sym,
                              "get#{type[0..-2].capitalize}Candidates".to_sym]

          required_methods.each do |m|
            test_class = "#{service.capitalize}Set"
            begin
              @ui.fail("#{test_class} lacks the required method #{m}.") unless eval "#{test_class}.method_defined?(:#{m})"
            rescue NameError
              @ui.fail("The service #{service} is not supported.")
            end
          end
        end
      end
    end
  end
end
