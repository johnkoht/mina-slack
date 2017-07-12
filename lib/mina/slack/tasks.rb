require 'json'
require 'net/http'
require 'openssl'


# Slack tasks
namespace :slack do

  task :starting do
    if fetch(:slack_url) and fetch(:slack_room)
      set(:start_time, Time.now)
      set(:last_revision, get_last_revision(last_revision_file))
    else
      print_local_status "Unable to create Slack Announcement, no slack details provided."
    end
  end

  task :finished do
    if fetch(:slack_url) and fetch(:slack_room)

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
    "#{fetch(:deploy_to)}/scm/FETCH_HEAD"
  end

  def get_last_revision(file_name)
    if File.exists?(file_name)
      lines = File.readlines(file_name).reject(&:empty?)
      lines.map do |line|
        return line.split.first
      end
    end
  end

  def short_revision
    deployed_revision = fetch(:deployed_revision)
    deployed_revision[0..7] if deployed_revision
  end

  def attachment_project
    {title: "New version of project", value: fetch(:application_name), short: true}
  end

  def attachment_enviroment
    {title: "Environment", value: fetch(:slack_stage), short: true}
  end

  def attachment_deployer
    {title: "Deployer", value: fetch(:deployer), short: true}
  end

  def attachment_revision
    {title: "Revision", value: "#{fetch(:application_name)}: #{fetch(:slack_stage)} #{short_revision}", short: true}
  end

  def attachment_changes
    {title: "Changes", value: fetch(:changes), short: false}
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
