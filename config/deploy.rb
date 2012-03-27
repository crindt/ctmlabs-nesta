require "bundler/vlad"

set :application, "ctmlabs-nesta"
set :repository,  "git@metis.its.uci.edu:ctmlabs-nesta"
set :deploy_to, "/Web/apps/#{application}"
set :revision, "origin/develop"
set :bundle_cmd, [ "source /usr/local/rvm/scripts/rvm",
                   "bundle"
                 ].join(" && ")

# following http://stackoverflow.com/questions/2371238/vlad-the-deployer-why-do-i-need-a-scm-folder
namespace :set do
  task :development do
    set :domain, "www-staging.ctmlabs.net"
    set :revision, "origin/develop"
  end
  
  task :production do
    set :domain, "www.ctmlabs.net"
    set :revision, "origin/master"
  end
end


task "vlad:deploy" => %w[
  vlad:update vlad:bundle:install vlad:start_app vlad:cleanup
]

task "vlad:development:deploy" => %w[
  set:development vlad:deploy
]

task "vlad:production:deploy" => %w[
  set:production vlad:deploy
]

