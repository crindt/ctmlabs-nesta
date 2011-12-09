require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

require 'nesta/env'
Nesta::Env.root = ::File.expand_path('.', ::File.dirname(__FILE__))

require 'nesta/app'

require 'rack-cas-client'

class MyNesta < Nesta::App
  use Rack::Session::Cookie
  use Rack::Cas::Client, :cas_base_url => 'https://cas.ctmlabs.net/cas', :enable_single_sign_out => true,  :cas_destination_logout_param_name => 'service', :session_dir => '/tmp/sessions', :service_url => 'http://localhost:9393/'
#, :authenticate_on_every_request => true
#, :validate_url => 'https://cas.ctmlabs.net/cas/serviceValidate'
  register Rack::Cas::ClientHelpers::Sinatra
end


run MyNesta
#run Nesta::App
