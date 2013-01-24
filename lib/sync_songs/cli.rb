# -*- coding: utf-8 -*-

require 'highline/import'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Command-line interface.
  class CLI
    QUIT_CHARACTER = 'q'
    YN_OPTIONS_MSG = 'Enter y for yes, n for no or q to quit'

    # Public: Constructs a command-line interface.
    #
    # verbose - True if interface is verbose (default: nil).
    def initialize(verbose = nil)
      @verbose = verbose
    end

    # Public: Asks for directions to write in and return them.
    #
    # services - An Set of services associated with types.
    #
    # Returns an array of Struct::Direction.
    def directions(services)
      directions = []

      say 'Enter direction to write in'

      # Ask for the direction of every combination of services.
      services.to_a.combination(2) do |c|
        question = [c.first, '?', c.last]
        input = ask("#{question.join(' ')} ") do |q|
          q.responses[:not_valid] = 'Enter < for to left, > for to right, = for both directions or q to quit'
          q.default = '='
          q.validate = /\A[<>=#{QUIT_CHARACTER}]\Z/i
        end

        exitOption(input)

        if @verbose
          question[1] = input
          say question.join(' ')
        end

        directions << Struct::Direction.new([Struct::Service.new(*c.first),
                                             Struct::Service.new(*c.last)],
                                            input.to_sym)
      end
      directions
    end

    def strict_search(service)
      input = ask("Use strict search for #{service.user} #{service.name} #{service.type}? ") do |q|
        q.responses[:not_valid] = "A strict search is recommended as a wide search may generate too many hits. #{YN_OPTIONS_MSG}"
        q.default = 'y'
        q.validate = /\A[yn#{QUIT_CHARACTER}]\Z/i
      end

      exitOption(input)

      service.strict_search = input.eql?('y') ? true : false
    end

    def interactive(service)
      input = ask("Interactive mode for #{service.user} #{service.name} #{service.type}? ") do |q|
        q.responses[:not_valid] = "In interactive mode you will for every found song be asked whether to add it. Interactive mode is recommended for everything but services you have direct access to, such as text files. #{YN_OPTIONS_MSG}"
        q.default = 'y'
        q.validate = /\A[yn#{QUIT_CHARACTER}]\Z/i
      end

      exitOption(input)

      service.interactive = input.eql?('y') ? true : false
    end

    def addSong?(song, service)
      input = ask("Add #{song} to #{service.name} #{service.type}? ") do |q|
        q.responses[:not_valid] = #{YN_OPTIONS_MSG}
          q.default = 'y'
        q.validate = /\A[yn#{QUIT_CHARACTER}]\Z/i
      end

      exitOption(input)

      input.eql?('y')
    end

    # Public: Shows failure message and exit.
    #
    # message   - The String failure message.
    # exception - The Exception causing the failure (default: nil).
    def fail(message, exception = nil)
      say message.strip     # Messages from Last.fm have leading spaces.
      if @verbose && exception
        p exception
        puts exception.backtrace
      end
      exit
    end

    def message(message)
      puts message
    end

    def verboseMessage(message)
      puts message if @verbose
    end

    # Public: Prints supported services.
    def self.supportedServices
      msg = []

      Controller.supportedServices.each do |service, type_action|
        type_msg = []
        type_action.each do |type, action|
          type_msg << "#{type} #{action}"
        end
        msg << "#{service}: #{type_msg.join(', ')}"
      end

      puts msg.join("\n")
    end

    private

    # Internal: Exits if input is a character for quitting.
    #
    # input - Input String from user.
    def exitOption(input)
      exit if input.casecmp(QUIT_CHARACTER) == 0
    end
  end
end
