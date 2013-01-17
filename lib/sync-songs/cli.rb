# -*- coding: utf-8 -*-

require 'highline/import'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Command-line interface
  class CLI
    @@QUIT_CHARACTER = 'q'

    # Public: Constructs a command-line interface.
    #
    # verbose - True if interface is verbose (default: nil).
    def initialize(verbose = nil)
      @verbose = verbose
    end

    # Public: Asks for directions to write in.
    #
    # services - A hash of services associated with types.
    #
    # Returns a hash of services associated with types of services and
    #   the input direction.
    def directions(services)
      directions = {}

      say 'Enter directions to write in.'

      # Ask for the direction of every combination of services.
      services.to_a.combination(2) do |c|
        question = [c.first, '<=>', c.last]
        input = ask("#{question.join(' ')} ") do |q|
          q.responses[:not_valid] = 'Enter < for to left, > for to right, = for both directions or q to quit.'
          q.default = '='
          q.validate = /\A[<>=#@@QUIT_CHARACTER]\Z/i
        end

        exitOption(input)

        inputDirectionToHash(input, directions, c)

        if @verbose
          question[1] = direction
          say question.join(' ') 
        end
      end
      
      directions
    end

    # Public: Shows failure message and exit.
    #
    # message   - The String failure message.
    # exception - The Exception causing the failure (default: nil).
    def fail(message, exception = nil)
      say message
      if @verbose
        p exception
        puts exception.backtrace
      end
      exit
    end

    private

    # Internal: Translate input of direction to a symbol and store it
    # in the given hash.
    #
    # input - User input String to translate.
    # hash  - Hash to write to.
    # data  - Data to associate with directions in hash.
    def inputDirectionToHash(input, hash, data)
      support = []

      case input
      when '<' then support << :w << :r
      when '=' then support << :rw << :rw
      when '>' then support << :r << :w
      end        

      data.each { |st| hash[st.shift.to_sym] = {st.shift.to_sym => support.shift} }
    end

    # Internal: Exits if input is a character for quitting.
    #
    # input - Input from user.
    def exitOption(input)
      exit if input.casecmp(@@QUIT_CHARACTER) == 0
    end
  end
end
