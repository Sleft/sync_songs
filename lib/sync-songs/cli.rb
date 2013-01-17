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
    # Returns an array of hashes with the services associated with
    #   direction (:r, :r or :rw).
    def getDirections(services)
      syncDirections = []

      say 'Enter directions to write in.'

      services.to_a.combination(2) do |c|
        direction_msg = [c.first, '<=>', c.last]
        direction = ask("#{direction_msg.join(' ')} ") do |q|
          q.responses[:not_valid] = 'Enter < for to left, > for to right, = for both directions or q to quit.'
          q.default = '='
          q.validate = /\A[<>=#@@QUIT_CHARACTER]\Z/i
        end

        exitOption(direction)

        syncDirections << case direction
                          when '<'
                            [{ c.first => :w },
                             { c.last => :r }]
                          when '='
                            [{ c.first => :rw },
                             { c.last => :rw }]
                            when '>'
                            [{ c.first => :r },
                             { c.last => :w }]
                          end

        if @verbose
          direction_msg[1] = direction
          say direction_msg.join(' ') 
        end
      end
      
      p syncDirections
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

    # Internal: Exits if input is a character for quitting.
    #
    # input - Input from user.
    def exitOption(input)
      exit if input.casecmp(@@QUIT_CHARACTER) == 0
    end
  end
end
