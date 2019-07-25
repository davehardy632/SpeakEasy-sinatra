require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'
require 'json'
require 'faraday'
require 'pry'
require './lib/message'
require './lib/shoutout'


class ShoutoutService

  def conn
    Faraday.new(url: 'http://localhost:3000') do |f|
      f.adapter Faraday.default_adapter
    end
  end

  def parsed_response(response)
    JSON.parse(response.body, symbolize_names: true)
  end

  def all_shoutouts
    parsed_response(conn.get("/api/v1/shoutouts"))
  end


  def aggregate_shoutouts
    all_shoutouts[:data].map do |shoutout_data|
      Shoutout.new(shoutout_data)
    end
  end

  def count_shoutouts
    aggregate_shoutouts
    "You have #{aggregate_shoutouts.count} new shoutouts"
  end

  def first_shoutout
    aggregate_shoutouts
    "Shoutout from #{aggregate_shoutouts.first.sender} to #{aggregate_shoutouts.first.sent_to}, #{aggregate_shoutouts.first.message}"
  end
end
