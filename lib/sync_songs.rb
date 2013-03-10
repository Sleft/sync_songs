# -*- coding: utf-8 -*-

require 'rubygems'
require 'bundler/setup'

# Path to the library
PATH = './sync_songs/'
SERVICES_PATH = "#{PATH}services/"

# Load the library
require_relative "#{PATH}cli"
require_relative "#{PATH}controller"
require_relative "#{PATH}version"

require_relative "#{SERVICES_PATH}service_controller"
require_relative "#{SERVICES_PATH}csv_controller"
require_relative "#{SERVICES_PATH}grooveshark_controller"
require_relative "#{SERVICES_PATH}lastfm_controller"

# Internal: A sync direction.
Struct.new('Direction', :services, :direction)

# Internal: A service to sync with.
Struct.new('Service',
           # Internal: A String naming the user name or the file path
           # for the service.
           :user,
           # Internal: A String naming the name of the service.
           :name,
           # Internal: A String naming the service type.
           :type,
           :action)
