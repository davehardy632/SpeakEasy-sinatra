require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'
require 'json'
require 'faraday'
require 'pry'
require './lib/message'
require './services/message_service'


class MessageService

  def conn
    Faraday.new(url: 'https://arrogant-loon-34609.herokuapp.com') do |f|
      f.adapter Faraday.default_adapter
    end
  end

  def parsed_response(response)
    JSON.parse(response.body, symbolize_names: true)
  end

  def messages
    parsed_response(conn.get("/api/v1/messages"))
  end

  def messages_by_creator(creator)
    aggregate_messages_by_creator(creator)[:data].map do |message_data|
      Message.new(message_data)
    end
  end

  def format_messages_by_creator(creator)
    messages = messages_by_creator(creator)
    string = "There are #{messages.count} messages by #{messages.first.creator}, messages read, "
    messages.each do |message|
      string << "#{message.commit_message}, with a build status of #{message.build_state}.  "
    end
    string
  end

  def aggregate_messages_by_creator(creator)
    parsed_response(conn.get("/api/v1/messages/find?#{creator}"))
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

  def last_message
    aggregate_messages
    "Last commit message, with a status of #{aggregate_messages.last.build_status} from #{aggregate_messages.last.creator}, it reads, #{aggregate_messages.last.commit_message}"
  end

end
