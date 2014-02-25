require 'rubygems'
require 'sinatra'
require 'slim'
require 'gibbon' # MailChimp
require 'dotenv'

require 'omniauth'
require 'omniauth-facebook'
require 'omniauth-github'
require 'omniauth-oauth2'
require 'omniauth-google-oauth2'

begin
  require 'pry-debugger'
rescue LoadError
  nil
end


class String
  def present?
    self =~ /[^[:space:]]/
  end
end

class NilClass
  def present?
    false
  end
end

def self.match(url, &block)
  get(url, &block)
  post(url, &block)
end

Dotenv.load

oauth_scopes = {
  'facebook' => { scope: 'email' },
  'github' => { scope: 'user:email' },
}

use Rack::Session::Cookie, secret: ENV['RANDOM_SECRET']
use OmniAuth::Builder do
  %w[facebook github google_oauth2].each do |provider|
    provider provider.to_sym,
      ENV["OAUTH_#{provider.upcase}_APPID"],
      ENV["OAUTH_#{provider.upcase}_SECRET"],
      oauth_scopes[provider] || {}
  end
end

#configure :production do
configure do

  # MailChimp configuration: ADD YOUR OWN ACCOUNT INFO HERE!
  set :mailchimp_api_key, ENV['MAILCHIMP_API_KEY']
  set :mailchimp_list_name, ENV['MAILCHIMP_LIST_NAME']
  set :mailchimp_list_id, ENV['MAILCHIMP_LIST_ID']

end

raise "Please specify MAILCHIMP_API_KEY in your environment" unless settings.mailchimp_api_key

gb = Gibbon::API.new(settings.mailchimp_api_key)

unless settings.mailchimp_list_id
  unless settings.mailchimp_list_name
    raise "Please specify MAILCHIMP_LIST_NAME or MAILCHIMP_LIST_ID in your environment"
  end
  unless (list = gb.lists.list({:filters => {:list_name => settings.mailchimp_list_name}})['data'].first)
    raise "No such list: #{settings.mailchimp_list_name}"
  end
  set :mailchimp_list_id, list['id']
end

subscribe = lambda { |email|
  gb.lists.subscribe(
    id: settings.mailchimp_list_id,
    email: { email: email },
    double_optin: false
  )
}

get '/' do
  slim :index
end

match '/auth/:name/callback' do
  auth = request.env['omniauth.auth']
  if (email = auth.info.email).present?
    puts "#" * 80
    puts "#{params[:name]}:#{email}"
    puts "#" * 80
  end
  redirect '/'
end

post '/signup' do
  if (email = params[:email]).present?
    subscribe(email)
    "Success."
  else
    "Give an email address, please"
  end
end
