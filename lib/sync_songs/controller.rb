# -*- coding: utf-8 -*-

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Controls syncing and diffing of sets of songs.
  class Controller
    INPUT_FORM = '[user|file path]:service:type'

    # Public: Creates a controller.
    #
    # ui    - The user interface to use.
    # input - A Set of Strings representing users or file paths paired
    #         with a service and a type on the form user:service:type,
    #         e.g. "user1:grooveshark:favorites",
    #         "user1:lastfm:loved".
    def initialize(ui, input)
      @ui = ui
      @input = input

      parseInput

      # Services to sync between. Stored in a hash so that one one may
      # check if a service is already stored and if that is the case
      # get a key to it. That way @directions can store keys to
      # @services.
      @services = {}

      # A Set of Struct::Direction (see sync_songs.rb). Each direction
      # should be unique therefore they are stored in a set.
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

      # Get the classes that extends ServiceController.
      classes = ObjectSpace.each_object(Class).select { |c| c < ServiceController }

      # Associate the class name with its supported services.
      classes.each do |c|
        class_name = c.name.split('::').last

        # Only accept classes that ends with 'Controller'.
        if match = class_name.match(/(\w+)Controller\Z/)
          services[match[1].downcase.to_sym] = c::SERVICES
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
    # (type) at Grooveshark (service) is supported. Fails if something
    # is not supported.
    def checkSupport
      supp_services = Controller.supportedServices

      @services.each do |_, s|
        msg = ' is not supported'

        # Is the service supported?
        msg = "#{s.name}#{msg}"
        @ui.fail(msg, 1) unless supp_services.key?(s.name)

        # Is the type supported?
        supp_types = supp_services[s.name]
        msg = "#{s.type} for #{msg}"
        @ui.fail(msg, 1) unless supp_types.key?(s.type)

        # Is the action supported?
        msg = "#{s.action} to #{msg}"
        supp_action = supp_types[s.type]
        @ui.fail(msg, 1) unless supp_action == s.action || supp_action == :rw
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
    # current favorites from Grooveshark and Last.fm. The data is
    # stored in each service controller. Exceptions for services
    # should not be handled here but in each service controller.
    def getCurrentData
      threads = []

      @services.each do |_, service|
        threads << Thread.new(service) do |s|
          @mutex.synchronize do
            @ui.verboseMessage("Getting #{s.type} from #{s.user} #{s.name}...")
          end
          s.send(s.type)
          @mutex.synchronize do
            @ui.verboseMessage("Got #{s.set.size} songs from "\
                               "#{s.user} #{s.name} #{s.type}")
          end
        end
      end

      threads.each { |t| t.join }
    end

    # Internal: Gets the search result from the services that should
    # be synced to. The data is stored in the search_result of each
    # service controller.
    def getSearchResults
      threads = []

      @directions.each do |direction|
        if direction.direction == :'<' || direction.direction == :'='
          threads << Thread.new(direction) do |d|
            search(@services[d.services.first],
                   @services[d.services.last])
          end
        end
        if direction.direction == :'>' || direction.direction == :'='
          threads << Thread.new(direction) do |d|
            search(@services[d.services.last],
                   @services[d.services.first])
          end
        end
      end

      threads.each { |t| t.join }
    end

    # Internal: Searches for songs that are exclusive to service2 at
    # service1, e.g. gets the search result on Grooveshark of the
    # songs that are exclusive to Last.fm. Exceptions for services
    # should not be handled here but in each service controller.
    #
    # s1    - Key to a service to search at.
    # s2    - Key to a service with songs to search for.
    def search(s1, s2)
      @mutex.synchronize do
        @ui.verboseMessage("Searching at #{s1.name} for songs from "\
                           "#{s2.user} #{s2.name} #{s2.type}...")
      end
      result = s1.search(s1.set.exclusiveTo(s2.set),
                           s1.strict_search)

      # Access to search result should be synchronized.
      @mutex.synchronize do
        s1.search_result.merge(result)
        @ui.verboseMessage("Found #{s1.search_result.size} "\
                           "candidates from #{s2.user} #{s2.name} "\
                           "#{s2.type} at #{s1.name}")
      end
    end

    # Internal: Ask for preferences of options for adding songs.
    def addPreferences
      @services.each do |_, s|
        # Add preferences are only relevant when one is writing to a
        # service.
        s.addPreferences if s.action == :w || s.action == :rw
      end
    end

    # Internal: Ask for preferences of options for searching for
    # songs.
    def searchPreferences
      @services.each do |_, s|
        # Search preferences are only relevant when one is writing to
        # a service.
        s.searchPreferences if s.action == :w || s.action == :rw
      end
    end

    # Internal: Gets data to be synced to each service.
    def getDataToAdd
      @services.each do |_, s|
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

      @services.each do |_, service|
        threads << Thread.new(service) do |s|
          if s.songs_to_add && !s.songs_to_add.empty?
            @mutex.synchronize do
              @ui.verboseMessage("Adding #{s.type} to #{s.name} #{s.user}...")
            end
            addSongs(s)
            @mutex.synchronize do
              @ui.verboseMessage("Finished adding #{s.type} to "\
                                 "#{s.name} #{s.user}")
            end
          end
        end
      end

      threads.each { |t| t.join }

      sayAddedSongs
    end

    # Internal: Adds songs to the given service. Exceptions should not
    # be handled here but in each service controller.
    #
    # s - The service to add songs to.
    def addSongs(s)
      s.added_songs = s.send("addTo#{s.type.capitalize}",
                             s.songs_to_add)
    end

    # Internal: For each found missing song in a service, ask whether
    # to add it to that service.
    #
    # s - The service to add songs to.
    def interactiveAdd(s)
      if s.search_result.size > 0
        @ui.message('Choose whether to add the following '\
                    "#{s.search_result.size} songs to "\
                    "#{s.user} #{s.name} #{s.type}:")
        @ui.askAddSongs(s)
      end
    end

    # Internal: Shows the difference for the services.
    def showDifference
      @services.each do |_, s|
        if s.songs_to_add
          @ui.message("#{s.songs_to_add.size} songs missing on "\
                      "#{s.user} #{s.name} #{s.type}:")
          s.songs_to_add.each do |song|
            @ui.message(song)
          end
        end
      end
    end

    # Internal: Store directions to sync in each service controller.
    def directionsToServices
      @directions.each do |d|
        support = []

        case d.direction
        when :'<' then support << :w << :r
        when :'=' then support << :rw << :rw
        when :'>' then support << :r << :w
        end

        d.services.each do |s|
          @services[s].action = support.shift
        end
      end
    end

    # Internal: Shows a message of which songs that was added.
    def sayAddedSongs
      counts_msg = []
      v_msg = []

      @services.each do |_, s|
        if s.added_songs
          counts_msg << "Added #{s.added_songs.size} songs to "\
          "#{s.user} #{s.name} #{s.type}"
          v_msg << s.added_songs.map { |song| "Added #{song} to #{s.user} #{s.name} #{s.type}" }
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

        @ui.fail('You must supply services on the form '\
                 "#{INPUT_FORM}", 2) if split_input.size != 3

        parsed_input << split_input
      end

      @ui.fail('You must supply at least two distinct'\
               ' services.', 2) if parsed_input.size < 2

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

      # Store the given answer.
      answers.each do |a|
        @directions << Struct::Direction.new([storeService(a.first),
                                              storeService(a.last)],
                                             a[1].to_sym)
      end
    end

    # Internal: Initializes and stores a service in @services and
    # returns its key.
    #
    # s - An array containing user/file name, type and action.
    #
    # Returns a reference to the stored service.
    def storeService(s)
      key = s.join.to_sym

      # Only initialize the service if it is not already initialized.
      @services[key] = initializeService(s) if not @services[key]

      key
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
