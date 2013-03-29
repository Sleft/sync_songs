# -*- coding: utf-8 -*-

require 'highline/import'

# Public: Classes for syncing sets of songs.
module SyncSongs
  # Public: Command-line interface.
  class CLI
    # Public: A character for answering yes to a question.
    YES_ANSWER = 'y'
    # Public: A character that the user can input to quit what is
    # currently happening. Sometimes it means to quit to program
    # altogether, sometimes it means to merely to quit the current
    # dialog.
    QUIT_ANSWER = 'q'
    # Public: Message asking for yes, no or quit.
    YN_OPTIONS_MSG = 'Enter y for yes, n for no or q to quit'
    # Public: Validator for yes, no or quit questions.
    YN_VALIDATOR = /\A[yn#{QUIT_ANSWER}]/i

    attr_reader :color

    # Public: Creates a command-line interface.
    #
    # verbose             - True if interface is verbose (default:
    #                       nil).
    # debug               - True if interface is in debug mode
    #                       (default: nil), this means e.g. that
    #                       backtraces for exceptions are printed.
    # color               - True if color formatted output should be
    #                       used (default: nil).
    # possible_directions - An hash of possible sync directions
    #                       between two given services mapped to
    #                       descriptions of those directions (default:
    #                       nil).
    def initialize(verbose = nil, debug = nil, color = nil,
                   possible_directions = nil)
      @verbose             = verbose
      @debug               = debug
      @possible_directions = possible_directions
      HighLine::use_color  = color

      directionsMessage if @possible_directions
      

      HighLine.color_scheme = HighLine::ColorScheme.new do |cs|
        cs[:verbose]           = [:blue]
        cs[:verbose_direction] = [:cyan, :bold]
        cs[:horizontal_line]   = [:red, :bold]
        cs[:even_row]          = [:green]
        cs[:odd_row]           = [:magenta]
       end

      @row = true         # To track even and odd rows for colorizing.
    end

    # Public: Asks for directions to write in and return them.
    #
    # directions - A two dimensional array where each element is of
    #              the form ['service1', '?', 'service2'].
    #
    # Returns an two dimensional array where each element is of the
    #   form ['service1', '</=/>', 'service2'].
    def askDirections(directions)
      directions.each do |d|
        d[1] = askDirection("#{d.join(' ')} ")

        exitOption(d[1])

        if @verbose
          say("<%= color(%q{#{d.first.join(' ')}}, :verbose) %> "\
              "<%= color(%q{#{d[1]}}, :verbose_direction) %> "\
              "<%= color(%q{#{d.last.join(' ')}}, :verbose) %>")
        end
      end

      directions
    end

    # Public: Asks if strict search should be used for the given
    # service.
    #
    # s - A Service to decide search method for.
    def strict_search(s)
      input = ask("Strict search for #{s.user} #{s.name} #{s.type}? ") do |q|
        q.responses[:not_valid] = 'A strict search is recommended '\
        'as a wide search may generate too many hits. '\
        "#{YN_OPTIONS_MSG}"
        q.default = YES_ANSWER
        q.validate = YN_VALIDATOR
      end

      exitOption(input)

      s.strict_search = if input.casecmp(YES_ANSWER) == 0
                          true
                        else
                          false
                        end
    end

    # Public: Asks if interactive mode should be used for the given
    # service and stores the answer in the service.
    #
    # s - A Service to decide interactive mode for.
    def interactive(s)
      input = ask("Interactive mode for #{s.user} #{s.name} "\
                  "#{s.type}? ") do |q|
        q.responses[:not_valid] = 'In interactive mode you will for '\
        'every found song be asked whether to add it. Interactive '\
        'mode is recommended for everything but services you have '\
        "direct access to, such as text files. #{YN_OPTIONS_MSG}"
        q.default = YES_ANSWER
        q.validate = YN_VALIDATOR
      end

      exitOption(input)

      s.interactive = if input.casecmp(YES_ANSWER) == 0
                        true
                      else
                        false
                      end
    end

    # Public: For every song in the search result of the given
    # service, ask whether to add it and store it if the user wants to
    # add it.
    #
    # services - A Set of services.
    def askAddSongs(service)
      service.search_result.each do |s|
        add = askAddSong(s, service)

        # Stop asking if the user press quit
        break if add.casecmp(QUIT_ANSWER) == 0

        service.songs_to_add << s if add.casecmp(YES_ANSWER) == 0
      end
    end

    # Public: Shows the given message and exits with the given exit
    # code.
    #
    # msg       - A String naming a failure message.
    # exit_code - Exit code to use, see
    #             http://tldp.org/LDP/abs/html/exitcodes.html for
    #             details (default: 1).
    # exception - The Exception causing the failure (default: nil).
    def fail(msg, exit_code = 1, exception = nil)
      failMessage(msg)
      if @debug && exception
        p exception
        puts exception.backtrace
      end
      exit(exit_code)
    end

    # Public: Shows the given message.
    #
    # msg - A String or an Enumerable naming a message.
    def message(msg)
      puts msg
    end

    # Public: Prints the given message if in verbose mode.
    #
    # msg - A String or an an Enumerable of Strings naming a verbose
    # message.
    def verboseMessage(msg)
      if @verbose
        if msg.respond_to? :each
          msg.each { |m| verboseMessage(m) }
        else
          say('<%= color(%q{' + msg + '}, BLUE) %>')
        end
      end
    end

    # Public: Shows the supported services.
    def supportedServices
      msg = []

      Controller.supportedServices.each do |service, type_action|
        type_msg = []
        type_action.each do |type, action|
          type_msg << "#{type} <%= color('#{action}', :even_row) %>"
        end
        msg << "<%= color('#{service}', BOLD) %>: #{type_msg.join(', ')}"
      end

      say(msg.join("\n"))
    end
    
    def possible_directions=(val)
      @possible_directions = val
      directionsMessage
    end

    private

    # Internal: Shows the given fail message.
    #
    # msg - A String or an Enumerable naming a message.
    def failMessage(msg)
      if msg.respond_to? :each
        msg.each { |m| failMessage(m) }
      else
        # Messages from Last.fm have leading spaces.
        say('<%= color(%q{' + msg.strip + '}, RED + BOLD) %>')
      end
    end

    # Internal: Asks whether to add the given song to the given
    # service.
    #
    # song    - A String naming a song.
    # service - A Service.
    def askAddSong(song, service)
      question = "<%= color(%q{Add #{song} to #{service.user} "\
      "#{service.name} #{service.type}?}, "
      question << (@row ? ':even_row' : ':odd_row')
      @row = !@row

      ask("#{question}) %> ") do |q|
        q.responses[:not_valid] = YN_OPTIONS_MSG
        q.default = YES_ANSWER
        q.validate = YN_VALIDATOR
      end
    end

    # Internal: Ask which direction to sync for the given services.
    #
    # question - A String naming a question asking for which direction
    #            to sync in between to services.
    #
    # Returns a String naming the direction to sync in.
    def askDirection(question)
      ask(question) do |q|
        q.responses[:not_valid] = @DIRECTIONS_MSG
        q.default = '='
        q.validate = lambda { |a| @possible_directions.key?(a.to_sym) || a == QUIT_ANSWER }
      end
    end

    # Internal: Exits if input is a character for quitting.
    #
    # input - Input String from user.
    def exitOption(input)
      exit if input.casecmp(QUIT_ANSWER) == 0
    end

    # Internal: Create a message describing what sync directions the
    # user can choose for any two services.
    def directionsMessage
      @DIRECTIONS_MSG = @possible_directions.map { |k, v| "<%= color('#{k}', :verbose_direction) %> for #{v}" }
      @DIRECTIONS_MSG = "Enter #{@DIRECTIONS_MSG.join(", ")}"
      @DIRECTIONS_MSG << " or <%= color('#{QUIT_ANSWER}', :verbose_direction) %> to quit"
    end
  end
end
