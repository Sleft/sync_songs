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
  end
end
