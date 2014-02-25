require 'rubygems'
require 'bundler/setup'

# Google Analytics: UNCOMMENT IF DESIRED, THEN ADD YOUR OWN ACCOUNT INFO HERE!
#require 'rack/google-analytics'
#use Rack::GoogleAnalytics, :tracker => "YOUR GOOGLE ANALYTICS ACCOUNT ID HERE"

$stdout.sync = true

require './app'
run Sinatra::Application

