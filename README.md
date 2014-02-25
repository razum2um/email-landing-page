Email Landing Page
============

A simple, customizable landing page for email signup, based on
[Twitter Bootstrap 3](https://github.com/twitter/bootstrap),
[HTML5 Boilerplate](https://github.com/h5bp/html5-boilerplate),
and [Sinatra](https://github.com/sinatra/sinatra).

The current version has optional MailChimp and Google Analytics integration.

Please visit the [live demo](http://email-landing.herokuapp.com/) on Heroku and join the project mailing list

## Requirenments

- Heroku application
- MailChimp account & list (list's name or id and account's api token)
- Social applications on Facebook, Google, Github (app_ids & tokens)

Note: configure your apps to have callback to

- http://host.com/auth/facebook/callback
- http://host.com/auth/google_oauth2/callback
- http://host.com/auth/github/callback

## Install

    bundle install
    heroku plugins:install git://github.com/ddollar/heroku-config.git
    cp env.example .env
    # edit `.env` file using ID's & tokens
    heroku config:push

## Run

To run locally you will need a reverse proxy to :9292 and corresponding record in /etc/hosts to test social apps

    rackup

To deploy

    git push heroku master

# Credits

Inspired by [quartzmo/email-landing-page](https://github.com/quartzmo/email-landing-page).
