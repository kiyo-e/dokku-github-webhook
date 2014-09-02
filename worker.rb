#!/usr/bin/env ruby
require 'sinatra'
require 'json'

dir = File.dirname(__FILE__)
COMMAND_SCRIPT = "#{dir}/commands"

set :environment, :production
set :port, 9292

post "/" do
  params = JSON.parse( request.body.read )

  if params["pull_request"]
    @app = params["pull_request"]["head"]["repo"]["name"]
    @url = params["pull_request"]["head"]["repo"]["ssh_url"]
    @ref = "refs/heads/" + params["pull_request"]["head"]["ref"]
  else
    @app = params["repository"]["name"]
    @url = params["repository"]["ssh_url"]
    @ref = params["ref"]
  end


  if params["action"] == "closed" or params["deleted"] == "true"
    system("#{COMMAND_SCRIPT} delete #{@app} #{@ref} #{@url}")
  else
    system("#{COMMAND_SCRIPT} webhook #{@app} #{@ref} #{@url}")
  end
end