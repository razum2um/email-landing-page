require 'rubygems'
require 'digest/sha1'
require 'sinatra'
require 'slim'
require 'gibbon' # MailChimp
require 'dotenv'
require 'rollbar'
require 'sinatra/flash'

require 'omniauth'
require 'omniauth-facebook'
require 'omniauth-github'
require 'omniauth-oauth2'
require 'omniauth-google-oauth2'

begin
  require 'pry-byebug'
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

Rollbar.configure do |config|
  config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
end

oauth_scopes = {
  'facebook' => { scope: 'email' },
  'github' => { scope: 'user:email' },
}

set :session_secret, ENV['RANDOM_SECRET']
enable :sessions
register Sinatra::Flash
use OmniAuth::Builder do
  %w[facebook github google_oauth2].each do |provider|
    provider provider.to_sym,
      ENV["OAUTH_#{provider.upcase}_APPID"],
      ENV["OAUTH_#{provider.upcase}_SECRET"],
      oauth_scopes[provider] || {}
  end
end

raise "Please specify MAILCHIMP_API_KEY in your environment" unless ENV['MAILCHIMP_API_KEY']
Gibbon::Request.api_key = ENV['MAILCHIMP_API_KEY']

raise "Please specify MAILCHIMP_LIST_ID in your environment" unless ENV['MAILCHIMP_LIST_ID']
subscribe = lambda { |email|
  begin
    Gibbon::Request.lists(ENV['MAILCHIMP_LIST_ID']).members.create(body: {
      email_address: email,
      status: 'subscribed'
    })
  rescue Gibbon::MailChimpError => e
    Rollbar.scoped(person: { id: Digest::SHA1.hexdigest(email), email: email }) do
      Rollbar.error(e)
    end
  end
}

get '/' do
  slim :index
end

match '/auth/:name/callback' do
  auth = request.env['omniauth.auth']
  if (email = auth.info.email).present?
    subscribe.call(email)
    flash[:info] = 'Thanks!'
  else
    flash[:error] = 'No email given by social network'
  end
  redirect '/'
end

post '/signup' do
  if (email = params[:email]).present?
    subscribe.call(email)
    flash[:info] = 'Thanks!'
  else
    flash[:error] = "Give an email address, please"
  end
  redirect '/'
end
