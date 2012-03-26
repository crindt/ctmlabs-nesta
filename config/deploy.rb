require "bundler/vlad"

namespace :vlad do
  namespace :development do
    set :application, "ctmlabs-nesta"
    set :repository,  "git@metis.its.uci.edu:ctmlabs-nesta"
    set :domain, "wwwdev.ctmlabs.net"
    set :deploy_to, "/Web/apps/#{application}"
    set :revision, "origin/develop"
    set :bundle_cmd, [ "source /usr/local/rvm/scripts/rvm",
                       "bundle"
                     ].join(" && ")
    task :deploy => %w[
      vlad:update vlad:bundle:install vlad:start_app vlad:cleanup
    ]
  end
  
  namespace :production do
    set :application, "ctmlabs-nesta"
    set :repository,  "git@metis.its.uci.edu:ctmlabs-nesta"
    set :domain, "www.ctmlabs.net"
    set :deploy_to, "/Web/apps/#{application}"
    set :revision, "origin/master"
    set :bundle_cmd, [ "source /usr/local/rvm/scripts/rvm",
                       "bundle"
                     ].join(" && ")
    task :deploy => %w[
      vlad:update vlad:bundle:install vlad:start_app vlad:cleanup
    ]
  end
end

