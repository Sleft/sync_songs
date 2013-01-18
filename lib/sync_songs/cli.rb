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
    # Returns an array of Structs, DirectionInput(:service, :type,
    # :action).
    def directions(services)
      directions = []

      say 'Enter directions to write in.'

      # Ask for the direction of every combination of services.
      services.to_a.combination(2) do |c|
        question = [c.first, '<=>', c.last]
        input = ask("#{question.join(' ')} ") do |q|
          q.responses[:not_valid] = 'Enter < for to left, > for to right, = for both directions or q to quit.'
          q.default = '='
          q.validate = /\A[<>=#{QUIT_CHARACTER}]\Z/i
        end

        exitOption(input)

        if @verbose
          question[1] = input
          say question.join(' ')
        end

        directions << inputDirectionToStruct(input, c)
      end
      directions.flatten
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

    # Internal: Translate input of direction to a Struct,
    # DirectionInput(:service, :type, :action), and store the Structs
    # in an array.
    #
    # input - User input String to translate.
    # data  - Array of arrays of services and types.
    #
    # Returns an array of Structs.
    def inputDirectionToStruct(input, data)
      support = []

      case input
      when '<' then support << :w << :r
      when '=' then support << :rw << :rw
      when '>' then support << :r << :w
      end

      data.map { |d| Struct::DirectionInput.new(d.first.to_sym,
                                                d.last.to_sym,
                                                support.shift) }
    end

    # Internal: Exits if input is a character for quitting.
    #
    # input - Input String from user.
    def exitOption(input)
      exit if input.casecmp(QUIT_CHARACTER) == 0
    end
  end
end
