set :application, "ctmlabs"
set :repository,  "ssh://crindt@parsons.its.uci.edu/home/crindt/ctmlabs-nesta.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/var/lib/nesta/#{application}"

role :web, "parsons.its.uci.edu"                          # Your HTTP server, Apache/etc
role :app, "parsons.its.uci.edu"                          # This may be the same as your `Web` server
role :db,  "parsons.its.uci.edu", :primary => true # This is where Rails migrations will run
role :db,  "parsons.its.uci.edu"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end







default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :domain, "parsons.its.uci.edu"
set :application, "ctmlabs"
set :deploy_to, "/var/lib/nesta/ctmlabs"

set :user, "crindt"
set :use_sudo, false

set :scm, "git"
set :repository,  "ssh://crindt@parsons.its.uci.edu/home/crindt/ctmlabs-nesta.git"
set :branch, 'master'
set :git_shallow_clone, 1

role :web, domain
role :app, domain
role :db,  domain, :primary => true

set :deploy_via, :remote_cache

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  # Assumes you are using Passenger
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

    # mkdir -p is making sure that the directories are there for some SCM's that don't save empty folders
    run <<-CMD
      rm -rf #{latest_release}/log &&
      mkdir -p #{latest_release}/public &&
      mkdir -p #{latest_release}/tmp &&
      ln -s #{shared_path}/log #{latest_release}/log
    CMD

    if fetch(:normalize_asset_timestamps, true)
      stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
      asset_paths = %w(images css).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
      run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
    end
  end
end
