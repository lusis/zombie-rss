$: << File.join(File.dirname(__FILE__), "lib")

require 'zombierss'
require 'sinatra'
require 'haml'
require 'uri'
require 'celluloid'

set :run, false

run ZombieRss::Web.new
