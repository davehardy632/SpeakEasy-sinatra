require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'
require 'json'
require 'faraday'
require 'pry'
require './lib/message'
require './lib/message_service'


post "/" do
  @messages = MessageService.new
  {
    version: "1.0",
    response: {
      outputSpeech: {
        type: "PlainText",
        text: "#{@messages.count_messages}, #{@messages.first_message}"
      }
    }
  }.to_json
end
# other speech types "ssml"
