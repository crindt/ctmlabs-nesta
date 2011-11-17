require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

require 'nesta/env'
Nesta::Env.root = ::File.expand_path('.', ::File.dirname(__FILE__))

require 'nesta/app'

require 'rack-cas-client'

class MyNesta < Nesta::App
  use Rack::Session::Cookie
  use Rack::Cas::Client, :cas_base_url => 'https://cas.ctmlabs.net/cas', :service_url => 'http://localhost:9393/', :enable_single_signout => true,  :cas_destination_logout_param_name => 'service', :session_dir => '/tmp/sessions'
  register Rack::Cas::ClientHelpers::Sinatra
end


run MyNesta
#run Nesta::App
