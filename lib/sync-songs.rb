# -*- coding: utf-8 -*-

# Path to Ruby code
PATH = './sync-songs/'

# Load the library
require_relative "#{PATH}cli"
require_relative "#{PATH}controller"
require_relative "#{PATH}grooveshark_cli"
require_relative "#{PATH}grooveshark_set"
require_relative "#{PATH}grooveshark_set"
require_relative "#{PATH}lastfm_cli"
Struct.new('DirectionInput', :service, :type, :action)
