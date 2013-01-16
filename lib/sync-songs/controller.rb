# -*- coding: utf-8 -*-

#require_relative '../sync-songs.rb'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controls syncing.
  class Controller

    # Public: Constructs a controller.
    #
    # services - An array of the services to sync.
    # type     - The type of sync to do.
    # ui       - The user interface to use.
    def initialize(services, type, ui)
      @services = services
      @type = type
      @ui = ui

      required_methods_defined?
      
      @sets = []
      
      @services.each do |s|
        # Init set UI
        @sets << (eval "#{s.capitalize}#{ui.class.name.split('::').last}.new").set
      end
      
      @sets.each { |s| p s.getFavorites }

      ui.getDirections(@services)

      # For each service initialize
      # Threads: For each service get data
      #          Save compare data
      # Ask for each missing song if it shall be synced (y/n)
      # Threads (if both directions): Set data

      # puts ObjectSpace.each_object(Class).select { |klass| klass < SongSet }
    end

    private

    # Internal: Raises NoMethodError if a required method for the
    # services in question is not defined. It is better to fail sooner
    # than later.
    def required_methods_defined?
      @required_set_methods = ["get#{@type.capitalize}".to_sym,
                               "addTo#{@type.capitalize}".to_sym,
                               "get#{@type[0..-2].capitalize}Candidates".to_sym]

      Struct.new("RequiredMethods", :class_suffix, :required_methods)
      classes_and_required_methods = [Struct::RequiredMethods.new('Set', @required_set_methods)]

      @services.each do |s|
        classes_and_required_methods.each do |c|
          c.required_methods.each do |m|
            test_class = "#{s.capitalize}#{c.class_suffix}"
            fail NoMethodError, "#{test_class} lacks the required method #{m}" unless eval "#{test_class}.method_defined?(:#{m})"
          end
        end
      end
    end
  end
end
