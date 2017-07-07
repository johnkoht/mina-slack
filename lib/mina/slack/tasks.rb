require 'mina/hooks'

require 'json'
require 'net/http'


# Before and after hooks for mina deploy
before_mina :deploy, :'slack:starting'
after_mina :deploy, :'slack:finished'


# Slack tasks
namespace :slack do

  task :starting do
    set(:start_time, Time.now)
    set(:last_revision, get_last_revision(last_revision_file))
    print_local_status "Unable to create Slack Announcement, no slack details provided."
  end

  task :finished do
    if slack_url and slack_room

      attachment = {
        fallback: "Required plain-text summary of the attachment.",
        color: "#36a64f",
        fields: [attachment_project, attachment_enviroment, attachment_deployer, attachment_revision, attachment_changes]
      }

      post_slack_attachment(attachment)
    else
      print_local_status "Unable to create Slack Announcement, no slack details provided."
    end
  end

  def last_revision_file
    "#{deploy_to}/scm/FETCH_HEAD"
  end

  def get_last_revision(file_name)
    if File.exists?(file_name)
      lines = File.readlines(file_name).reject(&:empty?)
      lines.map do |line|
        return line.split.first
      end
    end
  end

  def announced_stage
    slack_stage
  end

  def announced_deployer
    deployer
  end

  def short_revision
    deployed_revision[0..7] if deployed_revision
  end

  def announced_application_name
    "".tap do |output|
      output << slack_application if slack_application
      output << " `#{branch}`" if branch
      output << " (`#{short_revision}`)" if short_revision
    end
  end

  def attachment_project
    {title: "New version of project", value: application_name, short: true}
  end

  def attachment_enviroment
    {title: "Environment", value: slack_stage, short: true}
  end

  def attachment_deployer
    {title: "Deployer", value: deployer, short: true}
  end

  def attachment_revision
    {title: "Revision", value: "#{application_name}: #{slack_stage} #{short_revision}", short: true}
  end

  def attachment_changes
    {title: "Changes", value: changes, short: false}
  end

  def create_attachment
  end

  def post_slack_message(message)
    # Parse the URI and handle the https connection
    uri = URI.parse(slack_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    payload = {
      "parse"       => "full",
      "channel"     => slack_room,
      "username"    => slack_username,
      "text"        => message,
      "icon_emoji"  => slack_emoji
    }

    # Create the post request and setup the form data
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(:payload => payload.to_json)

    # Make the actual request to the API
    http.request(request)
  end

  def post_slack_attachment(attachment)
    uri = URI.parse(slack_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    payload = {
      "parse"       => "full",
      "channel"     => slack_room,
      "username"    => slack_username,
      "attachments" => [attachment],
      "icon_emoji"  => slack_emoji
    }

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(:payload => payload.to_json)

    http.request(request)
  end
end
