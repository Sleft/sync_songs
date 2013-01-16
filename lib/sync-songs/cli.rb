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
    # services - An array of services to sync.
    #
    # Returns an array of structs, SyncDirection, of two services and
    #   the direction to sync in.
    def getDirections(services)
      Struct.new("SyncDirection", :service1, :direction, :service2)
      syncDirections = []

      say 'Enter directions to write in.'

      services.combination(2) do |c|
        direction_msg = [c.first, '<=>', c.last]
        direction = ask("#{direction_msg.join(' ')} ") do |q|
          q.responses[:not_valid] = 'Enter < for to left, > for to right, = for both directions or q to quit.'
          q.default = '='
          q.validate = /\A[<>=#@@QUIT_CHARACTER]\Z/i
        end

        exitOption(direction)

        direction_msg[1] = direction
        say direction_msg.join(' ') if @verbose
        syncDirections << Struct::SyncDirection.new(*direction_msg)
      end
      
      syncDirections
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
