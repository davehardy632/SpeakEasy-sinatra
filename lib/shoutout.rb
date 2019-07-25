require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'
require 'json'
require 'faraday'
require 'pry'

class Shoutout

  attr_reader :user_name,
              :text,
              :command

  def initialize(shoutout_data)
    @user_name = shoutout_data[:attributes][:user_name]
    @text = shoutout_data[:attributes][:text]
    @command = shoutout_data[:attributes][:command]
  end

end
