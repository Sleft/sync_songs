# -*- coding: utf-8 -*-

require 'highline/import'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Command-line interface
  module CLI
    QUIT_CHARACTER = 'q'

    # Public: Asks for directions to write in.
    #
    # services - An array of services to sync.
    #
    # Returns an array of structs, SyncDirection, of two services and
    #   the direction to sync in.
    def self.getDirections(services)
      Struct.new("SyncDirection", :service1, :service2, :direction)
      syncDirections = []

      say 'Enter directions to write in.'

      services.combination(2) do |c|
        direction = ask("#{c.first} <=> #{c.last} ") do |q|
          q.responses[:not_valid] = 'Enter < for to left, > for to right, = for both directions or q to quit.'
          q.default = '='
          q.validate = /\A[<>=#{QUIT_CHARACTER}]\Z/i
        end

        exitOption(direction)
        syncDirections << Struct::SyncDirection.new(c.first, c.last, direction)
      end
      
      syncDirections
    end

    # Internal: Exits if input is a character for quitting.
    #
    # input - Input from user.
    def self.exitOption(input)
      exit if input.casecmp(QUIT_CHARACTER) == 0
    end

    private_class_method :exitOption
  end
end
