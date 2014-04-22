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
    require 'mina/slack/tasks'

### Setup Slack Details
You'll need to setup your slack details with an API key, room and subdomain. You can add these as ENV variables or in the deploy.rb

    # config/deploy.rb
    set :slack_token, 'SLACK_API_KEY'
    set :slack_room, '#slack_room'
    set :slack_subdomain, 'slack_subdomain'

Or use the ENV variables:

    ENV['SLACK_TOKEN'] = '' 
    ENV['SLACK_ROOM'] = ''
    ENV['SLACK_SUBDOMAIN'] = ''


## Contributing

1. Fork it ( http://github.com/<my-github-username>/mina-slack/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
