require 'sinatra'
require 'json'

dir = File.dirname(__FILE__)
COMMAND_SCRIPT = "#{dir}/commands"

class Worker < Sinatra::Base
  set :environment, :production

  post "/" do
    params = JSON.parse( request.body.read )
    app = params["repository"]["name"]
    url = params["repository"]["url"]
    ref = params["ref"]
    system("#{COMMAND_SCRIPT} webhook #{app} #{ref} #{url}")
  end
end
