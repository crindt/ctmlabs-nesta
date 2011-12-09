set :application, "ctmlabs"
set :repository,  "git@parsons.its.uci.edu:/home/crindt/ctmlabs-nesta.git"

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
