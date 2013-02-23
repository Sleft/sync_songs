# -*- coding: utf-8 -*-

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controls syncing and diffing of sets of songs.
  class Controller
    INPUT_FORM = '[user|file path]:service:type'

    # Public: Constructs a controller.
    #
    # ui    - The user interface to use.
    # input - An Set of Strings representing users or file paths
    #         paired with a service and a type on the form
    #         user@service:type, e.g. "user1.grooveshark:favorites",
    #         "user1:lastfm:loved".
    def initialize(ui, input)
      @ui = ui
      @input = input
      parseInput
      @services = Set.new
    end

    # Public: Syncs the song sets of the input services.
    def sync
      @ui.verboseMessage('Preparing to sync song sets')

      say 'Enter direction to write in'
      prepareServices

      addPreferences

      getData
      addData

      @ui.verboseMessage('Success')
    end

    # Public: Diffs the song sets of the input services.
    def diff
      @ui.verboseMessage('Preparing to diff song sets')

      say 'Enter direction to diff in'
      prepareServices

      getData
      showDifference

      @ui.verboseMessage('Success')
    end

    # Public: Returns a hash of services associated with their
    # supported types associated with supported action.
    #
    # Examples
    #
    #   Controller.supportedServices
    #   # => {:grooveshark=>{:favorites=>:rw}, :lastfm=>{:loved=>:rw,
    #        :favorites=>:rw}}
    def self.supportedServices
      services = {}

      # Get the classes that extends SongSet.
      classes = ObjectSpace.each_object(Class).select { |klass| klass < SongSet }

      # Associate the class name with its supported services.
      classes.each do |klass|
        class_name = klass.name.split('::').last

        # Only accept classes that ends with 'Set'.
        if match = class_name.match(/(\w+)Set\Z/)
          services[match[1].downcase.to_sym] = klass::SERVICES
        end
      end

      services
    end

    private

    # Internal: Prepare services for handling.
    def prepareServices
      # Get directions to sync in.
      @directions = @ui.directions(@input)

      # Translate directions to be able to check support.
      directionsToServices

      checkSupport

      @services.each { |s| initializeServiceUI(s) }
    end

    # Internal: Checks if the action and the type and for the input
    # service are supported, e.g. if reading (action) from favorites
    # (type) at Grooveshark (service) is supported. Fails via UI if
    # something is not supported.
    def checkSupport
      supported_services = Controller.supportedServices

      @services.each do |i|
        fail_msg = ' is not supported.'

        # Is the service supported?
        fail_msg = "#{i.name}#{fail_msg}"
        @ui.fail(fail_msg, 1) unless supported_services.key?(i.name)

        # Is the type supported?
        supported_types = supported_services[i.name]
        fail_msg = "#{i.type} for #{fail_msg}"
        @ui.fail(fail_msg, 1) unless supported_types.key?(i.type)

        # Is the action supported?
        fail_msg = "#{i.action} to #{fail_msg}"
        supported_action = supported_types[i.type]
        @ui.fail(fail_msg, 1) unless supported_action == i.action || supported_action == :rw
      end
    end

    # Internal: Gets the data for each service.
    def getData
      @ui.message('Getting data. This might take a while.')
      getCurrentData
      getSearchResults
      getDataToAdd
    end

    # Internal: Gets the current data from each service, e.g. the
    # current favorites from Grooveshark and Last.fm. The data is not
    # returned but stored in the set of the each service.
    def getCurrentData
      threads = []

      @services.each do |service|
        threads << Thread.new(service) do |s|
          @ui.verboseMessage("Getting #{s.type} from #{s.user} #{s.name}...")
          begin
            s.ui.send(s.type)
          rescue Grooveshark::GeneralError, Lastfm::ApiError,
            SocketError, Timeout::Error => e
            @ui.fail(e.message.strip, 1, e)
          end
          @ui.verboseMessage("Got #{s.set.size} #{s.type} from #{s.user} #{s.name}")
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
            search(d.services.first, d.services.last)
          end
        end
        threads << Thread.new(direction) do |d|
          if d.direction == :'>' || d.direction == :'='
            search(d.services.last, d.services.first)
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
    # Raises ArgumentError from xml-simple some reason (see
    #   LastfmSet).
    # Raises Errno::EINVAL if the network connection fails.
    # Raises Grooveshark::GeneralError if the network connection
    #   fails.
    # Raises SocketError if the network connection fails.
    # Raises Timeout::Error if the network connection fails.
    def search(service1, service2)
      @ui.verboseMessage("Searching #{service1.name}...")

      # Is the following 6 lines thread safe?
      unless service1.search_result
        service1.search_result = SongSet.new
      end

      begin
        service1.search_result += service1.set.send(:search, service2.set, service1.strict_search)
      rescue ArgumentError,Errno::EINVAL, Grooveshark::GeneralError,
        SocketError, Timeout::Error => e
        @ui.fail(e.message.strip, 1, e)
      end

      @ui.verboseMessage("Found #{service1.search_result.size} candidates for #{service1.user} #{service1.name} #{service1.type}")
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

    # Internal: Gets data to be synced to each service.
    def getDataToAdd
      @directions.each do |d|
        d.services.each do |s|
          if s.interactive      # Add songs interactively
            interactiveAdd(s)
          else                  # or add them all without asking.
            s.songs_to_add = s.search_result
          end
        end
      end
    end

    # Internal: Adds the data to be synced to each service.
    def addData
      @ui.message('Adding data. This might take a while.')
      threads = []

      @services.each do |service|
        threads << Thread.new(service) do |s|
          if s.songs_to_add && !s.songs_to_add.empty?
            @ui.verboseMessage("Adding #{s.type} to #{s.name} #{s.user}...")
            addSongs(s)
            @ui.verboseMessage("Finished adding #{s.type} to #{s.name} #{s.user}")
          end
        end
      end

      threads.each { |t| t.join }

      sayAddedSongs
    end

    # Internal: Adds songs to the given service.
    #
    # service - The service to add songs to.
    def addSongs(service)
      service.added_songs = service.ui.send("addTo#{service.type.capitalize}", service.songs_to_add)
    rescue Grooveshark::GeneralError, SocketError => e
      @ui.fail("Failed to add #{service.type} to #{service.name} #{s.user}\n#{e.message.strip}", 1, e)
    end

    # Internal: For each found missing song in a service, ask whether
    # to add it to that service.
    def interactiveAdd(service)
      service.songs_to_add = SongSet.new

      if service.search_result.size > 0
        @ui.message("Choose whether to add the following #{service.search_result.size} songs to #{service.user} #{service.name} #{service.type}:")
        @ui.askAddSongs(service)
      end
    end

    # Internal: Shows the difference for the services.
    def showDifference
      @services.each do |service|
        if service.search_result
          @ui.message("#{service.search_result.size} songs missing on #{service.user} #{service.name} #{service.type}:")
          service.search_result.each do |s|
            @ui.message(s)
          end
        end
      end
    end

    # Internal: Try to initialize the UI for the given service and get
    # a reference to its song set which is then stored in the
    # Struct::Service.
    #
    # service - A Struct::Service.
    def initializeServiceUI(service)
      service_ui = "#{service.name.capitalize}#{@ui.class.name.split('::').last}"
      service.ui = SyncSongs.const_get(service_ui).new(service, @ui)
    rescue NameError => e
      @ui.fail("Failed to initialize #{service_ui}.", 1, e)
    end

    # Internal: Translate directions to sync in to an array of
    # Struct::Service.
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

    # Internal: Sends a message of which songs that was added to the
    # UI.
    def sayAddedSongs
      counts_msg = []
      v_msg = []

      @services.each do |service|
        if service.added_songs
          counts_msg << "Added #{service.added_songs.size} songs to #{service.user} #{service.name} #{service.type}"
          v_msg << service.added_songs.map { |s| "Added #{s} to #{service.user} #{service.name} #{service.type}" }
        end
      end

      if v_msg.empty? && counts_msg.empty?
        @ui.message('Nothing done')
      else
        @ui.verboseMessage(v_msg)
        @ui.message(counts_msg)
      end
    end

    # Internal: Parse the input from a set with elements of the form
    # user@service:type to an array of the form [[:user1, :service,
    # :type], [:user1, :service, :type]] and complain if the input is
    # bad.
    def parseInput
      parsed_input = Set.new

      @input.each do |s|
        # Split the delimited input except where the delimiter is
        # escaped and remove the escaping characters.
        split_input = s.split(/(?<!\\):/).map { |e| e.gsub(/\\:/, ':').to_sym }

        @ui.fail("You must supply services on the form #{INPUT_FORM}", 2) if split_input.size != 3

        parsed_input << split_input
      end

      @ui.fail('You must supply at least two distinct services.', 2) if parsed_input.size < 2

      @input = parsed_input
    end
  end
end
