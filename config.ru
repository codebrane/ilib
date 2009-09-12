#require 'rubygems'
require 'sinatra'
require 'json'
require 'net/http'
require 'rest_client'
require 'ilib'

# http://groups.google.com/group/phusion-passenger/browse_thread/thread/b1b50891b0f91fea
class NginxPassengerFix
  def initialize(app)
    @app = app
  end

  def call(env)
    # Very dodgy hax to correct the PATH_INFO
    env["PATH_INFO"] = env["REQUEST_URI"].sub(/\?[^\?]*$/, "")
    r = @app.call(env)
  end
end

use NginxPassengerFix

run Sinatra::Application