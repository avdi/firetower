require 'yammer4r'
require 'oauth'

# OAuth details for Yamfire

# Consumer (Application) Key
# nZ2KdW4zxEHNAkfnxnMJA
# Consumer (Application) Secret
# jO4ILOhKjf8IIFG0m4cStu9BTvovWQXghpOYuNHbk
# Request Token URL
# https://www.yammer.com/oauth/request_token
# Access Token URL
# https://www.yammer.com/oauth/access_token
# Authorize URL
# https://www.yammer.com/oauth/access_token

module Firetower::Plugins
  class Yamfire < Firetower::Session::Listener
    CONSUMER_KEY    = "nZ2KdW4zxEHNAkfnxnMJA"
    CONSUMER_SECRET = "jO4ILOhKjf8IIFG0m4cStu9BTvovWQXghpOYuNHbk"

  end
end
