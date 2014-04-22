before_mina :deploy, :'slack:starting'
after_mina :deploy, :'slack:finished'

namespace :slack do
  puts "slack..."
  set :deployer, ENV['GIT_AUTHOR_NAME'] || `git config user.name`.chomp

  task :starting do
    puts "starting..."
    puts "deployer:: #{deployer}"

    puts "slack_token:: #{slack_token}"
    puts "slack_room:: #{slack_room}"
    puts "slack_subdomain:: #{slack_subdomain}"
    
    if slack_token and slack_room and slack_subdomain
      announced_stage = ENV['to'] || 'production'

      announcement = "#{deployer} is deploying #{app}'s #{branch} to #{announced_stage}"

      # Parse the API url and create an SSL connection
      uri = URI.parse("https://#{slack_subdomain}.slack.com/services/hooks/incoming-webhook?token=#{slack_token}")
      puts "uri:: #{uri}"
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      # Create the post request and setup the form data
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(payload: {channel: slack_room, username: 'deploybot', text: announcement, icon_emoji: ':ghost:'}.to_json)

      # Make the actual request to the API
      response = http.request(request)
      puts "response:: #{response.inspect}"

      set :start_time, Time.now
    else
      print_local_status "Unable to create Slack Announcement, no slack details provided."
    end
  end


  
  task :finished do
    puts "finished..."

    if slack_token and slack_room and slack_subdomain
      announced_stage = ENV['to'] || 'production'

      end_time = Time.now
      start_time = start_time
      elapsed = end_time.to_i - start_time.to_i

      announcement = "#{deployer} deployed #{app} successfully in #{elapsed} seconds."

      # Parse the URI and handle the https connection
      uri = URI.parse("https://#{slack_subdomain}.slack.com/services/hooks/incoming-webhook?token=#{slack_token}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      # Create the post request and setup the form data
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(:payload => {channel: slack_room, username: 'deploybot', text: msg, icon_emoji: ":ghost:"}.to_json)
      
      # Make the actual request to the API
      response = http.request(request)
    else
      print_local_status "Unable to create Slack Announcement, no slack details provided."
    end
  end
end