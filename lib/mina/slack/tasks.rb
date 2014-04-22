require 'mina/hooks'

require 'json'
require 'net/http'

require 'mina/slack/defaults'



# Before and after hooks for mina deploy
before_mina :deploy, :'slack:starting'
after_mina :deploy, :'slack:finished'


# Slack tasks
namespace :slack do

  task :starting do
    if slack_token and slack_room and slack_subdomain
      announced_stage = ENV['to'] || 'production'
      announcement = "#{deployer} is deploying #{app}'s #{branch} to #{announced_stage}"

      # Parse the API url and create an SSL connection
      uri = URI.parse("https://#{slack_subdomain}.slack.com/services/hooks/incoming-webhook?token=#{slack_token}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      # Create the post request and setup the form data
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(payload: {channel: slack_room, username: 'deploybot', text: announcement, icon_emoji: ':ghost:'}.to_json)

      # Make the actual request to the API
      response = http.request(request)
    else
      print_local_status "Unable to create Slack Announcement, no slack details provided."
    end
  end


  
  task :finished do
    if slack_token and slack_room and slack_subdomain
      announced_stage = ENV['to'] || 'production'
      announcement = "#{deployer} successfully deployed #{app} to #{announced_stage}!"

      # Parse the URI and handle the https connection
      uri = URI.parse("https://#{slack_subdomain}.slack.com/services/hooks/incoming-webhook?token=#{slack_token}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      # Create the post request and setup the form data
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(payload: {channel: slack_room, username: 'deploybot', text: announcement, icon_emoji: ':ghost:'}.to_json)

      # Make the actual request to the API
      response = http.request(request)
    else
      print_local_status "Unable to create Slack Announcement, no slack details provided."
    end
  end
end