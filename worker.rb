#!/usr/bin/env ruby
require 'sinatra'
require 'json'
require 'eventmachine'
class MyApp < Sinatra::Base
  @@jobs = []

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

    command = if params["action"] == "closed" or params["deleted"] == "true"
                "#{COMMAND_SCRIPT} delete #{@app} #{@ref} #{@url}"
              elsif %w( opened reopened synchronize ).include?(params["action"])
                "#{COMMAND_SCRIPT} webhook #{@app} #{@ref} #{@url}"
              end

    @@jobs.push command
    status 200 && return
  end

  EM::defer do
    loop do
      sleep 5
      next if @@jobs.empty?
      job = @@jobs.shift ## ジョブ1つ取り出す
      ## job処理する
      system(job)
    end
  end

  run! if app_file == $0
end
