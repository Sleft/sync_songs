# -*- coding: utf-8 -*-

require 'set'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controls syncing.
  class Controller

    # Public: Constructs a controller.
    #
    # action   - A Symbol naming the action to perform.
    # services - A hash of services associated with types.
    # ui       - The user interface to use.
    def initialize(action, input_services, ui)
      @action = action
      @ui = ui
      ui.fail('You must supply at least two distinct services.') if @services.size < 2

      @input_directions = ui.directions(input_services) if @action == :sync

      supported_services = Controller.services
      
      if @action == :sync
        # Check if service, type and action are supported
        @input_directions.each do |input_service, input_support|
          fail_msg = " is not supported."
          input_type = input_support.keys.first
          input_action = input_support.values.first

          # Is service supported?
          fail_msg = "#{input_service}#{fail_msg}"
          ui.fail(fail_msg) unless supported_services.key?(input_service)

          # Is type supported?
          p supported_types = supported_services[input_service]
          fail_msg = "#{input_type} for #{fail_msg}"
          ui.fail(fail_msg) unless supported_types.key?(input_type)

          # Is action supported?
          fail_msg = "#{input_action} to #{fail_msg}"
          supported_action = supported_types[input_type]
          ui.fail(fail_msg) unless supported_action == input_action || supported_action == :rw
        end
      elsif @action == :diff
        ui.fail(fail_msg) unless supported_action == :r || supported_action == :rw
      end
      
      input_services.each { |s, _| initializeUI(s) }

      @sets = []

      @sets.each { |s| p s.getFavorites }


      # For each service initialize
      # Threads: For each service get data
      #          Save compare data
      # Ask for each missing song if it shall be synced (y/n)
      # Threads (if both directions): Set data

    end
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
