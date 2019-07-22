require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'
require 'json'
require 'faraday'
require 'pry'
require './lib/message'


class MessageService

  def conn
    Faraday.new(url: 'http://localhost:3000') do |f|
      f.adapter Faraday.default_adapter
    end
  end

  def messages
    parsed_response(conn.get("/api/v1/messages"))
  end

  def parsed_response(response)
    JSON.parse(response.body, symbolize_names: true)
  end

  def aggregate_messages
    messages[:data].map do |message_data|
      Message.new(message_data)
    end
  end

  def count_messages
    aggregate_messages
    "You have #{aggregate_messages.count} new build message updates"
  end

  def first_message
    aggregate_messages
    "First commit message, with a status of #{aggregate_messages.first.build_status} from #{aggregate_messages.first.creator}, it reads, #{aggregate_messages.first.commit_message}"
  end

end
