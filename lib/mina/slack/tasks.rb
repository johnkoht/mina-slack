require 'json'
require 'net/http'
require 'openssl'


# Slack tasks
namespace :slack do

  task :finished do
    if fetch(:slack_url) and fetch(:slack_room)
      ssh_fetch_command = %x[ssh #{fetch(:domain)} cat #{fetch(:current_path)}/.mina_git_revision]
      set(:last_revision, ssh_fetch_command.delete("\n"))
      print_status "Last commit #{fetch(:last_revision)}"
      attachment = {
        fallback: "Required plain-text summary of the attachment.",
        color: "#36a64f",
        fields: [attachment_project, attachment_enviroment, attachment_deployer, attachment_revision, attachment_changes]
      }

      post_slack_attachment(attachment)
    else
      print_status "Unable to create Slack Announcement, no slack details provided."
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
    uri = URI.parse(fetch(:slack_url))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    payload = {
      "parse"       => "full",
      "channel"     => fetch(:slack_room),
      "username"    => fetch(:slack_username),
      "attachments" => [attachment],
      "icon_emoji"  => fetch(:slack_emoji)
    }

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(:payload => payload.to_json)

    http.request(request)
  end
end
