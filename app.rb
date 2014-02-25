require 'rubygems'
require 'sinatra'
require 'slim'
require 'gibbon' # MailChimp
require 'pry-debugger' rescue nil

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

get '/' do
  slim :index
end

post '/signup' do
  if (email = params[:email].to_s.strip) =~ /[^[:space:]]/
    gb.lists.subscribe(
      id: settings.mailchimp_list_id,
      email: { email: email },
      double_optin: false
    )
    "Success."
  else
    "Give an email address, please"
  end
end
