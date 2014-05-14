# Mina::Slack

Announce Mina deployments to a slack channel.

## Installation

Add this line to your application's Gemfile:

    gem 'mina-slack'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mina-slack

## Usage

### Load the recipe
Include the recipe in your deploy.rb

    # config/deploy.rb
    require 'mina/slack'

### Setup Slack Details
You'll need to setup your slack details with an API key, room and subdomain. You can add these as ENV variables or in the config/deploy.rb

    # required
    set :slack_token, "webhook_token" # comes from inbound webhook integration
    set :slack_room, "#general" # the room to send the message to
    set :slack_subdomain, "example" # if your subdomain is example.slack.com

    # optional
    set :slack_application, "Application Name" # override Capistrano `application`
    set :slack_username, "Deploy Bot" # displayed as name of message sender
    set :slack_emoji, ":cloud:" # will be used as the avatar for the message

Or use the ENV variables:

    # required
    ENV['SLACK_TOKEN'] = ''
    ENV['SLACK_ROOM'] = ''
    ENV['SLACK_SUBDOMAIN'] = ''

    # optional
    ENV['SLACK_APPLICATION'] = ''
    ENV['SLACK_USERNAME'] = ''
    ENV['SLACK_EMOJI'] = ''

## Contributing

1. Fork it ( http://github.com/<my-github-username>/mina-slack/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
