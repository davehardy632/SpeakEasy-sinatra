require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'
require 'json'
require 'faraday'
require 'pry'


class Message

  attr_reader :build_status, :build_state, :commit_message, :creator

  def initialize(message_data)
    @build_status = message_data[:attributes][:build_status]
    @build_state = message_data[:attributes][:build_state]
    @commit_message = message_data[:attributes][:commit_messages]
    @creator = message_data[:attributes][:creator]
  end

end
