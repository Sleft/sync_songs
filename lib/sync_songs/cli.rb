# -*- coding: utf-8 -*-

require 'highline/import'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Command-line interface.
  class CLI
    QUIT_CHARACTER = 'q'

    # Public: Constructs a command-line interface.
    #
    # verbose - True if interface is verbose (default: nil).
    def initialize(verbose = nil)
      @verbose = verbose
    end

    # Public: Asks for directions to write in and return them.
    #
    # services - A hash of services associated with types.
    #
    # Returns an array of Struct::Direction.
    def directions(services)
      directions = []

      say 'Enter directions to write in'

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

        directions << Struct::Direction.new([Struct::Service.new(c.first.first.to_sym,
                                                                 c.first.last.to_sym),
                                             Struct::Service.new(c.last.first.to_sym,
                                                                 c.last.last.to_sym)],
                                            input.to_sym)
      end
      directions
    end

    def strict_search(service)
      if service.set.takesParameter('strict_search')
        input = ask('Do you want to make a strict search? ') do |q|
          q.responses[:not_valid] = 'A strict search is recommended as a wide search may generate too many hits. Enter y for yes, n for no or q to quit'
          q.default = 'y'
          q.validate = /\A[yn#{QUIT_CHARACTER}]\Z/i
        end

        input.eql?('y') ? service.strict_search = true : service.strict_search = false
      end
    end

    def interactive(service)
      input = ask('For every found song, do you want to asked whether to add it (interactive mode)? ') do |q|
        q.responses[:not_valid] = 'Interactive mode is recommended for everything but services you have direct access to, such as text files. Enter y for yes, n for no or q to quit'
        q.default = 'y'
        q.validate = /\A[yn#{QUIT_CHARACTER}]\Z/i
      end

      input.eql?('y') ? service.interactive = true : service.interactive = false
    end

    def interactiveAdd(song, service)
      input = ask('Do you want to add #{song} to #{service.name}? ') do |q|
        q.responses[:not_valid] = 'Enter y for yes, n for no or q to quit'
        q.default = 'y'
        q.validate = /\A[yn#{QUIT_CHARACTER}]\Z/i
      end

      input.eql?('y')
    end

    # Public: Shows failure message and exit.
    #
    # message   - The String failure message.
    # exception - The Exception causing the failure (default: nil).
    def fail(message, exception = nil)
      say message
      if @verbose && exception
        p exception
        puts exception.backtrace
      end
      exit
    end

    def verboseMessage(message)
      say message if @verbose
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

      say msg.join("\n")
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
