# -*- coding: utf-8 -*-

require 'rubygems'
require 'bundler/setup'

PATH = './sync_songs/'
SERVICES_PATH = "#{PATH}services/"

# Load the library.
require_relative "#{PATH}cli"
require_relative "#{PATH}controller"
require_relative "#{PATH}version"

require_relative "#{SERVICES_PATH}service_controller"

# Load sub classes of ServiceController.
require_relative "#{SERVICES_PATH}csv_controller"
require_relative "#{SERVICES_PATH}grooveshark_controller"
require_relative "#{SERVICES_PATH}lastfm_controller"

# Internal: A sync direction.
Struct.new('Direction',
           # Internal: An array of two services to sync between.
           :services,
           # Internal: The direction to sync in.
           :direction)
