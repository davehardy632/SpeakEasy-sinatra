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
require './handlers/intent_request_handler'

class RequestRouter
  attr_reader :json_response
  def initialize(json_response)
    @json_response = json_response
  end

  def response_type
    json_response
    json_response["request"]["type"]
  end

  def format_response
    if json_response["request"]["type"] == "LaunchRequest"
      launch_response = LaunchResponse.new
      launch_response.render_response
    elsif json_response["request"]["type"] == "IntentRequest"
      IntentRequestHandler.new(json_response).route_intents
    end
  end


 #
 #  def workflow_message_count
 #    {"version"=>"1.0",
 # "session"=>
 #  {"new"=>false,
 #   "sessionId"=>"amzn1.echo-api.session.4ebe30bf-f4f1-4c9c-8331-f0987d95aef3",
 #   "application"=>{"applicationId"=>"amzn1.ask.skill.0d6e40fc-5ef3-4140-b147-29fd1e52f213"},
 #   "attributes"=>{"key"=>"value"},
 #   "user"=>
 #    {"userId"=>
 #      "amzn1.ask.account.AFOF3NCONU322QAD4DYBVUWSAJOO7O7JOZEFV6FVT4ZMRIBSKYKJAY5DA77SZX4QUXSY4VYCUKUOHKH3HM5TVG4QBPRXU6PJC757L4FNIMSRDJKAQDI6ZM3OOOV47KRWSVIAWERUKC5TD6UCXTHO55ZMS6VURQCRUM4FVLZZX4ILDTGMQ5MNL5FXLXH26TWAGEDMPPS57ZOXHEQ"}},
 # "context"=>
 #  {"System"=>
 #    {"application"=>{"applicationId"=>"amzn1.ask.skill.0d6e40fc-5ef3-4140-b147-29fd1e52f213"},
 #     "user"=>
 #      {"userId"=>
 #        "amzn1.ask.account.AFOF3NCONU322QAD4DYBVUWSAJOO7O7JOZEFV6FVT4ZMRIBSKYKJAY5DA77SZX4QUXSY4VYCUKUOHKH3HM5TVG4QBPRXU6PJC757L4FNIMSRDJKAQDI6ZM3OOOV47KRWSVIAWERUKC5TD6UCXTHO55ZMS6VURQCRUM4FVLZZX4ILDTGMQ5MNL5FXLXH26TWAGEDMPPS57ZOXHEQ"},
 #     "device"=>
 #      {"deviceId"=>
 #        "amzn1.ask.device.AFGRS35FYVENNNESLC572RO7VBWIGVBZG22H6YWG3L73BCXBOH2N4N7MGD6QDV5ZGC3CHFNROKR6UPSB7F4KY2QAR7IE2VVTDAQLC55ZQW5FGPKSW4HN6FJNZMVDBLQVMMJBCNF4EBPXNSDCV2LUMZ74J42XJP5LOLDLQGDE4MIN6F3A7UVYC",
 #       "supportedInterfaces"=>{}},
 #     "apiEndpoint"=>"https://api.amazonalexa.com",
 #     "apiAccessToken"=>
 #      "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IjEifQ.eyJhdWQiOiJodHRwczovL2FwaS5hbWF6b25hbGV4YS5jb20iLCJpc3MiOiJBbGV4YVNraWxsS2l0Iiwic3ViIjoiYW16bjEuYXNrLnNraWxsLjBkNmU0MGZjLTVlZjMtNDE0MC1iMTQ3LTI5ZmQxZTUyZjIxMyIsImV4cCI6MTU2NDAxMjU2NCwiaWF0IjoxNTY0MDEyMjY0LCJuYmYiOjE1NjQwMTIyNjQsInByaXZhdGVDbGFpbXMiOnsiY29udGV4dCI6IkFBQUFBQUFBQUFDQ0NidWFvN0pnSVVmQ1p3UUlXUlJsS2dFQUFBQUFBQUM4TjM3SGZPTEhLWmZNSXpmMXNWTWpRa1luOG9XdVlRQ3krVHJzQzJNZ0F0WldmdE1nUWh5OUIwZ2xuQ1pUZ3RuMGo0Vm1sOXVKZEJyVWdPVnNUTkpzdnRCaTk5SEQvY1BsSUwxY2RNUHo2UTBvZWs4TFpmY3kvOHRrY0JzcHhzSjBqcXFtdjVOT2drYlFSQXVtU25ObnI4R1JsMWxuSmgyT3Z1dlZsWlc0QkpZcDkzbHowT216OGZMeHhGc0ZtRk11V25zcVJjZEtSLzNYeTU3M1g2cDIrZkVCdmlkVjJ2SEt1SXJRT3VrNnVlampDZkZndzlFMk9xckJHUTMrdFZ0c3FWb0dueUdLUklqcWN2ejRzMnAzeDRjV2ErQVA3VU0xVE9MSUdHTWJJY1A3K1ZoNGpFSHN6VnZDQ2tuK0Z2R25yNkYwRHZpQ284Y3FMYzNNZ0xGbnpjRXBjZ3lTVW1HVWlNRXVaWHh6eGFPMWRpZWUvTUgxY3NRbXVEU0hQOXlreS80N3RDcDRmN1RxIiwiY29uc2VudFRva2VuIjpudWxsLCJkZXZpY2VJZCI6ImFtem4xLmFzay5kZXZpY2UuQUZHUlMzNUZZVkVOTk5FU0xDNTcyUk83VkJXSUdWQlpHMjJINllXRzNMNzNCQ1hCT0gyTjRON01HRDZRRFY1WkdDM0NIRk5ST0tSNlVQU0I3RjRLWTJRQVI3SUUyVlZUREFRTEM1NVpRVzVGR1BLU1c0SE42RkpOWk1WREJMUVZNTUpCQ05GNEVCUFhOU0RDVjJMVU1aNzRKNDJYSlA1TE9MRExRR0RFNE1JTjZGM0E3VVZZQyIsInVzZXJJZCI6ImFtem4xLmFzay5hY2NvdW50LkFGT0YzTkNPTlUzMjJRQUQ0RFlCVlVXU0FKT083TzdKT1pFRlY2RlZUNFpNUklCU0tZS0pBWTVEQTc3U1pYNFFVWFNZNFZZQ1VLVU9IS0gzSE01VFZHNFFCUFJYVTZQSkM3NTdMNEZOSU1TUkRKS0FRREk2Wk0zT09PVjQ3S1JXU1ZJQVdFUlVLQzVURDZVQ1hUSE81NVpNUzZWVVJRQ1JVTTRGVkxaWlg0SUxEVEdNUTVNTkw1RlhMWEgyNlRXQUdFRE1QUFM1N1pPWEhFUSJ9fQ.EBH_WyfIsrYrGeM5FWi79RHUZdUBPTJx1NaWuGR_uhsW-18oPnhO-0NueKe5_nrrVqvxuAKNPFbG4GSkU_hRg6C4TmrnTZKB9-ab_XTVvzHbjqsuh2ixc2o09OzpvYWZPP9OlLEGPoVxrHorm-NqDU7lxNADyAk8f-8exWS1964q_vddGPWXfD-ssfQ2Uws7AF1nR2BwbSde-47EbDGMV0c13Sa442FqG2h5n-Lr4xG60RzigNM1ES3pixpvj7cWxHE2S3h1HRGnwGaTZciQgs7M72wuS311LDXNOeXASJy_XISNsQIY8TeOITH_79vIbKfmLs3q3XIH4V7XPkhTrg"},
 #   "Viewport"=>
 #    {"experiences"=>[{"arcMinuteWidth"=>246, "arcMinuteHeight"=>144, "canRotate"=>false, "canResize"=>false}],
 #     "shape"=>"RECTANGLE",
 #     "pixelWidth"=>1024,
 #     "pixelHeight"=>600,
 #     "dpi"=>160,
 #     "currentPixelWidth"=>1024,
 #     "currentPixelHeight"=>600,
 #     "touch"=>["SINGLE"],
 #     "video"=>{"codecs"=>["H_264_42", "H_264_41"]}}},
 # "request"=>
 #  {"type"=>"IntentRequest",
 #   "requestId"=>"amzn1.echo-api.request.062f6129-a8c8-4ca3-89ea-76d00332970c",
 #   "timestamp"=>"2019-07-24T23:51:04Z",
 #   "locale"=>"en-US",
 #   "intent"=>{"name"=>"workflow_message_count", "confirmationStatus"=>"CONFIRMED"},
 #   "dialogState"=>"COMPLETED"}}
 #
 #
 #  end


end
