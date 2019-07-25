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

class MessageFormatter

  def format_messages(message_data)
        {
      "version": "1.0",
      "sessionAttributes": {
        "key": "value"
      },
      "response": {
        "outputSpeech": {
          "type": "PlainText",
          "text": "#{message_data}",
          "playBehavior": "REPLACE_ENQUEUED"
        },
        "card": {
          "type": "Simple",
          "title": "Response to a LaunchRequest",
          # "text": "Text content for a standard card",
          # "image": {
          #   "smallImageUrl": "https://url-to-small-card-image...",
          #   "largeImageUrl": "https://url-to-large-card-image..."
          # }
        },
        "reprompt": {
          "outputSpeech": {
            "type": "PlainText",
            "text": "Are you still there?, You can ask about workflow from a github project, and shoutouts from a predefined slack group",
            "playBehavior": "REPLACE_ENQUEUED"
          }
        },
        # "directives": [
        #   {
        #     "type": "InterfaceName.Directive"
        #     (...properties depend on the directive type)
        #   }
        # ],
        "shouldEndSession": false
      }
    }.to_json
  end

end
