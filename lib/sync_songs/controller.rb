# -*- coding: utf-8 -*-

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controls syncing and diffing of sets of songs.
  class Controller
    INPUT_FORM = '[user|file path]:service:type'

    # Public: Creates a controller.
    #
    # ui    - The user interface to use.
    # input - An Set of Strings representing users or file paths
    #         paired with a service and a type on the form
    #         user:service:type, e.g. "user1:grooveshark:favorites",
    #         "user1:lastfm:loved".
    def initialize(ui, input)
      @ui = ui
      @input = input

      parseInput

      # Services to sync between.
      @services = Set.new

      # Directions to sync in. Each direction should be unique
      # therefore they are stored in a set.
      @directions = Set.new

      # For synchronization of access to shared data when using
      # threads, e.g. of writing of search results.
      @mutex = Mutex.new
    end

    # Public: Syncs the song sets of the input services.
    def sync
      @ui.verboseMessage('Preparing to sync song sets')

      @ui.message('Enter direction to write in')
      prepareServices

      searchPreferences
      addPreferences

      getData
      addData

      @ui.verboseMessage('Success')
    end

    # Public: Diffs the song sets of the input services.
    def diff
      @ui.verboseMessage('Preparing to diff song sets')

      @ui.message('Enter direction to diff in')
      prepareServices

      searchPreferences

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
      classes = ObjectSpace.each_object(Class).select { |klass| klass < ServiceController }

      # Associate the class name with its supported services.
      classes.each do |klass|
        class_name = klass.name.split('::').last

        # Only accept classes that ends with 'Controller'.
        if match = class_name.match(/(\w+)Controller\Z/)
          services[match[1].downcase.to_sym] = klass::SERVICES
        end
      end

      services
    end

    private

    # Internal: Prepare services for handling.
    def prepareServices
      # Get directions to sync in.
      getDirections

      # Translate directions to be able to check support.
      directionsToServices

      checkSupport
    end

    # Internal: Checks if the action and the type and for the input
    # service are supported, e.g. if reading (action) from favorites
    # (type) at Grooveshark (service) is supported. Fails via UI if
    # something is not supported.
    def checkSupport
      supported_services = Controller.supportedServices

      @services.each do |s|
        fail_msg = ' is not supported.'

        # Is the service supported?
        fail_msg = "#{s.name}#{fail_msg}"
        @ui.fail(fail_msg, 1) unless supported_services.key?(s.name)

        # Is the type supported?
        supported_types = supported_services[s.name]
        fail_msg = "#{s.type} for #{fail_msg}"
        @ui.fail(fail_msg, 1) unless supported_types.key?(s.type)

        # Is the action supported?
        fail_msg = "#{s.action} to #{fail_msg}"
        supported_action = supported_types[s.type]
        @ui.fail(fail_msg, 1) unless supported_action == s.action || supported_action == :rw
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
          s.send(s.type)
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
            search(d.services.first,
                   d.services.last)
          end
        end
        threads << Thread.new(direction) do |d|
          if d.direction == :'>' || d.direction == :'='
            search(d.services.last,
                   d.services.first)
          end
        end
      end

      threads.each { |t| t.join }

      @services.each do |s|
        if s.search_result
          @ui.verboseMessage("Found #{s.search_result.size} candidates for #{s.user} #{s.name} #{s.type}")
        end
      end
    end

    # Internal: Searches for songs that are exclusive to service2 at
    # service1, e.g. gets the search result on Grooveshark of the
    # songs that are exclusive to Last.fm.
    #
    # s1    - Service to search.
    # s2    - Service with songs to search for.
    def search(s1, s2)
      @ui.verboseMessage("Searching at #{s1.name} for songs from #{s2.user} #{s2.name} #{s2.type}...")
      result = s1.search(s1.set.exclusiveTo(s2.set),
                           s1.strict_search)

      # Access to search result should be synchronized.
      @mutex.synchronize do
        s1.search_result = SongSet.new unless s1.search_result
        s1.search_result += result
      end
    end

    # Internal: Ask for preferences of options for adding songs.
    def addPreferences
      @services.each do |s|
        # Add preferences are only relevant when one is writing to a
        # service.
        s.addPreferences if s.action == :w || s.action == :rw
      end
    end

    # Internal: Ask for preferences of options for searching for
    # songs.
    def searchPreferences
      @services.each do |s|
        # Search preferences are only relevant when one is writing to
        # a service.
        s.searchPreferences if s.action == :w || s.action == :rw
      end
    end

    # Internal: Gets data to be synced to each service.
    def getDataToAdd
      @services.each do |s|
        if s.interactive      # Add songs interactively
          interactiveAdd(s)
        else                  # or add them all without asking.
          s.songs_to_add = s.search_result
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
      service.added_songs = service.send("addTo#{service.type.capitalize}",
                                         service.songs_to_add)
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
        if service.songs_to_add
          @ui.message("#{service.songs_to_add.size} songs missing on #{service.user} #{service.name} #{service.type}:")
          service.songs_to_add.each do |s|
            @ui.message(s)
          end
        end
      end
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

    # Internal: Parse the input from an array with elements of the
    # form user@service:type to a set of arrays of the form [[:user1,
    # :service, :type], [:user1, :service, :type]] and complain if the
    # input is bad.
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

    # Internal: Get directions to sync in and store them and the
    # related services.
    def getDirections
      questions = []

      # Get directions for every possible combination of services.
      @input.to_a.combination(2) do |c|
        questions << [c.first, '?', c.last]
      end

      answers = @ui.askDirections(questions)

      # Store answer.
      answers.each do |a|
        @directions << Struct::Direction.new([storeService(a.first),
                                              storeService(a.last)],
                                             a[1].to_sym)
      end
    end

    # Internal: Initializes and stores a service in @services and
    # returns its reference.
    #
    # s - An array containing user/file name, type and action.
    #
    # Returns a reference to the stored service.
    def storeService(s)
      service = initializeService(s)
      @services << service

      service
    end

    # Internal: Try to initialize the given service and return a
    # reference to it.
    #
    # s - An array containing user/file name, type and action.
    #
    # Returns a reference to a service.
    def initializeService(s)
      SyncSongs.const_get("#{s[1].capitalize}Controller").new(*s, @ui)
    rescue NameError => e
      @ui.fail("#{s[1]} is not supported.", 1, e)
    end
  end
end
