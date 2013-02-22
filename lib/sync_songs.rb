# -*- coding: utf-8 -*-

require 'rubygems'
require 'bundler/setup'

# Path to the library
PATH = './sync_songs/'

# Load the library
require_relative "#{PATH}cli"
require_relative "#{PATH}controller"
require_relative "#{PATH}grooveshark_cli"
require_relative "#{PATH}grooveshark_set"
require_relative "#{PATH}lastfm_cli"
require_relative "#{PATH}lastfm_set"
require_relative "#{PATH}version"

# Internal: A service to sync with.
Struct.new('Service', :user, :name, :type, :action,
           :set, :ui, :strict_search, :interactive,
           :search_result, :songs_to_add, :added_songs)

# Internal: A sync direction.
Struct.new('Direction', :services, :direction)
