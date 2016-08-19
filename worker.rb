#!/usr/bin/env ruby
# coding: utf-8
require 'sinatra'
require 'json'
require 'eventmachine'
require 'logger'

class MyApp < Sinatra::Base
  @@jobs = []
  @@current_job = ""

  dir = File.dirname(__FILE__)
  COMMAND_SCRIPT = "#{dir}/commands"

  set :environment, :production
  set :port, 9292
  
  configure do
    enable :logging
    file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
    file.sync = true
    use Rack::CommonLogger, file
  end

  get "/" do
    tasks = @@jobs.map {|x| x[:app]}
    erb "現在処理中のジョブ：#{@@current_job} <br> 処理待ち：#{tasks}"
  end

  post "/" do
    params = JSON.parse( request.body.read )

    logger.info params

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

    @@jobs.push({ :command => command, :app => @ref.sub(/refs\/heads\//, "") })
    @@jobs.uniq!
    logger.info @@jobs

    status 200 && return
  end

  EM::defer do
    loop do
      sleep 5
      next if @@jobs.empty?
      job = @@jobs.shift ## ジョブ1つ取り出す
      ## job処理する
      begin
        @@current_job = job[:app]
        system(job[:command])
      ensure
          @@current_job = nil
      end
    end
  end

  run! if app_file == $0
end
