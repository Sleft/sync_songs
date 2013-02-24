# -*- coding: utf-8 -*-

require 'highline/import'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Command-line interface.
  class CLI
    # Public: A character that the user can input to quit what is
    # currently. Sometimes quit is to quit to program, sometimes quit
    # is merely to quit the current dialog.
    QUIT_CHARACTER = 'q'
    YN_OPTIONS_MSG = 'Enter y for yes, n for no or q to quit'

    # Public: Constructs a command-line interface.
    #
    # verbose - True if interface is verbose (default: nil).
    # debug   - True if interface is in debug mode (default: nil),
    #           this means e.g. that backtraces for exceptions are
    #           printed.
    def initialize(verbose = nil, debug = nil)
      @verbose = verbose
      @debug   = debug
    end

    # Public: Asks for directions to write in and return them.
    #
    # services - A Set of services.
    #
    # Returns an array of Struct::Direction.
    def askDirections(directions)
      directions.each do |d|
        d[1] = askDirection("#{d.join(' ')} ")

        exitOption(d[1])

        d.join(' ') if @verbose
      end

      directions
    end

    def strict_search(service)
      input = ask("Strict search for #{service.user} #{service.name} #{service.type}? ") do |q|
        q.responses[:not_valid] = "A strict search is recommended as a wide search may generate too many hits. #{YN_OPTIONS_MSG}"
        q.default = 'y'
        q.validate = /\A[yn#{QUIT_CHARACTER}]\Z/i
      end

      exitOption(input)

      service.strict_search = input.casecmp('y') ? true : false
    end

    def interactive(service)
      input = ask("Interactive mode for #{service.user} #{service.name} #{service.type}? ") do |q|
        q.responses[:not_valid] = "In interactive mode you will for every found song be asked whether to add it. Interactive mode is recommended for everything but services you have direct access to, such as text files. #{YN_OPTIONS_MSG}"
        q.default = 'y'
        q.validate = /\A[yn#{QUIT_CHARACTER}]\Z/i
      end

      exitOption(input)

      service.interactive = input.casecmp('y') ? true : false
    end

    # Public: For every song in the search result of the given
    # service, ask whether to add it and store it if the user wants to
    # add it.
    #
    # services - A Set of services.
    def askAddSongs(service)
      service.search_result.each do |s|
        add = askAddSong(s, service)

        if add.casecmp('y') == 0
          service.songs_to_add << s
        # Stop asking if the user press quit
        elsif add.casecmp(QUIT_CHARACTER) == 0
          break
        end
      end
    end

    # Public: Shows failure message and exit.
    #
    # message   - The String failure message.
    # exit_code - Exit code to use, see
    #             http://tldp.org/LDP/abs/html/exitcodes.html for
    #             details (default : 1).
    # exception - The Exception causing the failure (default: nil).
    def fail(message, exit_code = 1, exception = nil)
      say message.strip   # Messages from Last.fm have leading spaces.
      if @debug && exception
        p exception
        puts exception.backtrace
      end
      exit(exit_code)
    end

    # Public: Prints the given message.
    #
    # msg - Message to print.
    def message(msg)
      puts msg
    end

    # Public: Prints the given message if in verbose mode.
    #
    # msg - Message to print.
    def verboseMessage(msg)
      message(msg) if @verbose
    end

    # Public: Prints the given message if in debug mode. Can e.g. be
    # used at different stages in the controller to debug it.
    #
    # object - Object to inspect.
    # msg    - Message to print, e.g. to describe program status.
    #
    # Examples
    #
    #   @ui.debugMessage(@services, 'Services before support check:')
    def debugMessage(object, msg = nil)
      if @debug
        puts msg if msg
        p object
      end
    end

    # Public: Prints the supported services.
    def self.supportedServices
      msg = []

      Controller.supportedServices.each do |service, type_action|
        type_msg = []
        type_action.each do |type, action|
          type_msg << "#{type} #{action}"
        end
        msg << "#{service}: #{type_msg.join(', ')}"
      end

      puts msg
    end

    private

    # Internal: Asks whether to add the given song to the given service.
    #
    # song    - A String naming a song.
    # service - A Service.
    def askAddSong(song, service)
      input = ask("Add #{song} to #{service.user} #{service.name} #{service.type}? ") do |q|
        q.responses[:not_valid] = #{YN_OPTIONS_MSG}
        q.default = 'y'
        q.validate = /\A[yn#{QUIT_CHARACTER}]\Z/i
      end
    end

    # Internal: Ask which direction to sync for the given services.
    #
    # question - A String naming a question asking for which direction
    #            to sync in between to services.
    #
    # Returns a String naming the direction to sync in.
    def askDirection(question)
      input = ask(question) do |q|
        q.responses[:not_valid] = 'Enter < for to left, > for to right, = for both directions or q to quit'
        q.default = '='
        q.validate = /\A[<>=#{QUIT_CHARACTER}]\Z/i
      end
    end

    # Internal: Exits if input is a character for quitting.
    #
    # input - Input String from user.
    def exitOption(input)
      exit if input.casecmp(QUIT_CHARACTER) == 0
    end
  end
end
