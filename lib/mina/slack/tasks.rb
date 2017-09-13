# Slack tasks
namespace :slack do
  task :post_info do
    if (url = fetch(:slack_url)) && (room = fetch(:slack_room))
      if set?(:user)
        Net::SSH.start(fetch(:domain), fetch(:user)) do |ssh|
          set(:last_revision, ssh.exec!("cd #{fetch(:deploy_to)}/scm; git log #{fetch(:branch)} -n 1 --pretty=format:'%H'"))
        end
      else
        login_data = fetch(:domain).split('@')
        Net::SSH.start(login_data[1], login_data[0]) do |ssh|
          set(:last_revision, ssh.exec!("cd #{fetch(:deploy_to)}/scm; git log #{fetch(:branch)} -n 1 --pretty=format:'%H'"))
        end
      end

      set(:last_commit, `git log #{fetch(:branch)} -n 1 --pretty=format:"%H"`)
      changes
      send_slack_message(slack_deploy_message, url)
    else
      print_status 'Unable to create Slack Announcement, no slack details provided.'
    end
  end
end
