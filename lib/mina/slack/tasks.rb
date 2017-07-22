require 'json'
require 'net/http'
require 'openssl'
require 'net/ssh'

# Slack tasks
namespace :slack do
  task :post_info do
    if (url = fetch(:slack_url)) && (room = fetch(:slack_room))
      if set?(:user)
        Net::SSH.start(fetch(:domain), fetch(:user)) do |ssh|
          set(:last_revision, ssh.exec!("cd #{fetch(:deploy_to)}/scm; git log -n 1 --pretty=format:'%H'"))
        end
      else
        login_data = fetch(:domain).split('@')
        Net::SSH.start(login_data[1], login_data[0]) do |ssh|
          set(:last_revision, ssh.exec!("cd #{fetch(:deploy_to)}/scm; git log -n 1 --pretty=format:'%H'"))
        end
      end

      set(:last_commit, `git log -n 1 --pretty=format:"%H"`)
      changes
      attachment = {
        fallback: 'Required plain-text summary of the attachment.',
        color: '#36a64f',
        fields: [attachment_project, attachment_enviroment, attachment_deployer, attachment_revision, attachment_changes]
      }

      message = {
        'parse'       => 'full',
        'channel'     => room,
        'username'    => fetch(:slack_username),
        'attachments' => [attachment],
        'icon_emoji'  => fetch(:slack_emoji)
      }

      send_slack_message(message, url)
    else
      print_status 'Unable to create Slack Announcement, no slack details provided.'
    end
  end

  def short_revision
    deployed_revision = fetch(:deployed_revision)
    deployed_revision[0..7] if deployed_revision
  end

  def attachment_project
    { title: 'New version of project', value: fetch(:slack_application), short: true }
  end

  def attachment_enviroment
    { title: 'Environment', value: fetch(:slack_stage), short: true }
  end

  def attachment_deployer
    { title: 'Deployer', value: fetch(:deployer), short: true }
  end

  def attachment_revision
    { title: 'Revision', value: "#{fetch(:slack_application)}: #{fetch(:slack_stage)} #{short_revision}", short: true }
  end

  def attachment_changes
    { title: 'Changes', value: fetch(:changes), short: false }
  end

  def send_slack_message(message, slack_url)
    uri = URI.parse(slack_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(payload: message.to_json)

    http.request(request)
  rescue Encoding::InvalidByteSequenceError
    comment 'Invalid byte sequence'
  end

  def changes
    last_revision = fetch(:last_revision)
    if last_revision.empty?
      set(:changes, `git --no-pager log --pretty=format:'Commit: %h - %ad%n%an - %s%n' --date=short --abbrev-commit #{fetch(:deployed_revision)}`)
    else
      set(:changes, `git --no-pager log --pretty=format:'Commit: %h - %ad%n%an - %s%n' --date=short --abbrev-commit #{fetch(:last_revision)}...#{fetch(:last_commit)}`)
    end
  end
end
