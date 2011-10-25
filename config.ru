$: << File.join(File.dirname(__FILE__), "lib")

require 'zombierss'
require 'sinatra'

set :run, false

run ZombieRss::Web.new
