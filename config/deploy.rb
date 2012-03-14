require "bundler/vlad"

set :application, "ctmlabs-nesta"
set :repository,  "git@metis.its.uci.edu:ctmlabs-nesta"
set :domain, "wwwdev.ctmlabs.net"
set :deploy_to, "/Web/apps/#{application}"
set :revision, "origin/develop"
set :bundle_cmd, [ "source /usr/local/rvm/scripts/rvm",
                    "bundle"
                  ].join(" && ")

task "vlad:deploy" => %w[
  vlad:update vlad:bundle:install vlad:start_app vlad:cleanup
]
