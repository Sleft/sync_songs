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

require_relative "#{SERVICES_PATH}csv_cli"
require_relative "#{SERVICES_PATH}csv_set"
require_relative "#{SERVICES_PATH}grooveshark_cli"
require_relative "#{SERVICES_PATH}grooveshark_set"
require_relative "#{SERVICES_PATH}lastfm_cli"
require_relative "#{SERVICES_PATH}lastfm_set"

# Internal: A service to sync with.
Struct.new('Service',
           # Internal: A String naming the user name or the file path
           # for the service.
           :user,
           # Internal: A String naming the name of the service.
           :name,
           # Internal: A String naming the service type.
           :type,
           :action,
           :set, :ui, :strict_search, :interactive,
           :search_result, :songs_to_add, :added_songs)

# Internal: A sync direction.
Struct.new('Direction', :services, :direction)
