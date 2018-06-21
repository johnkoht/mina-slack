# Required
set :slack_url,       -> { ENV['SLACK_URL'] }
set :slack_room,        -> { ENV['SLACK_ROOM'] }
# Optional
set :slack_stage,       -> { ENV['SLACK_STAGE'] || ENV['to'] || fetch(:rails_env, 'production') }
set :slack_application, -> { ENV['SLACK_APPLICATION'] || application }
set :slack_username,    -> { ENV['SLACK_USERNAME'] || 'deploybot' }
set :slack_emoji,       -> { ENV['SLACK_EMOJI'] || ':cloud:' }
# Git
set :deployer,          -> { ENV['GIT_AUTHOR_NAME'] || %x[git config user.name].chomp }
set :deployed_revision, -> { ENV['GIT_COMMIT'] || %x[git rev-parse #{branch}].strip }
