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
require './responses/launch_response'

post "/" do
launch_response = RequestRouter.new(JSON.parse(request.body.read))
launch_response.format_response
  # LaunchRequestHandler.new()
  # {
  #   version: "1.0",
  #   response: {
  #     outputSpeech: {
  #       type: "PlainText",
  #       text: "#{@messages.count_messages}, #{@messages.first_message}"
  #     }
  #   }
  # }.to_json
end

# other speech types "ssml"
