# Slack tasks
namespace :slack do
  task :post_info do
    if (url = fetch(:slack_url)) && (room = fetch(:slack_room))
      login_data = if (user = fetch(:user))
        [ fetch(:domain), user ]
      else
        # "bob@127.5.1.2".split('@')
        fetch(:domain).split('@').reverse
      end
      
      Net::SSH.start(login_data[0], login_data[1]) do |ssh|
        set(:last_revision, ssh.exec!("cd #{fetch(:deploy_to)}/scm; git log -n 1 --pretty=format:'%H' #{fetch(:branch)} --"))
      end

      set(:last_commit, `git log -n 1 --pretty=format:"%H" origin/#{fetch(:branch)} --`)
      changes
      send_slack_message(slack_deploy_message, url)
    else
      print_status 'Unable to create Slack Announcement, no slack details provided.'
    end
  end
end
