set :deployer, ENV['GIT_AUTHOR_NAME'] || `git config user.name`.chomp
set :announced_stage, ENV['to'] || 'production'

set :slack_token, ENV['SLACK_TOKEN']
set :slack_room, ENV['SLACK_ROOM']
set :slack_subdomain, ENV['SLACK_SUBDOMAIN']