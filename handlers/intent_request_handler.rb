require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'
require 'json'
require 'faraday'
require 'pry'
require './lib/message'
require './services/message_service'
require './services/shoutout_service'
require './routers/request_router'
require './formatters/message_formatter'

class IntentRequestHandler
  attr_reader :json_response
  def initialize(json_response)
    @json_response = json_response
  end

  def find_intent
    json_response["request"]["intent"]["name"]
  end

  def route_intents
    if find_intent == "workflow_message_count"
      message_service = MessageService.new
      message_formatter = MessageFormatter.new
      message_formatter.format_messages(message_service.count_messages)
    elsif find_intent == "newest_workflow_message"
      message_service = MessageService.new
      message_formatter = MessageFormatter.new
      message_formatter.format_messages(message_service.last_message)
    elsif find_intent = "messages_by_creator"
      message_service = MessageService.new
      message_formatter = MessageFormatter.new
      creator = json_response["request"]["intent"]["slots"]["name"]["value"]
      message_service.format_messages_by_creator(creator)
      message_formatter.format_messages(message_service.format_messages_by_creator(creator))
    end
  end

end
