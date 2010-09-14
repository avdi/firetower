require 'firetower/plugins/yamfire/yamfire.rb'
require 'yaml/store'
require 'launchy'
require 'oauth/signature/plaintext'

mode "yammer" do
  fattr(:yammer_config_path) { dir + "yammer.conf" }
  fattr(:yammer_config) {
    YAML::Store.new(yammer_config_path.to_s)
  }
  fattr(:yammer_client) {
    yammer_config.transaction(true) do |config|
      Yammer::Client.new(
        :consumer => {
          :key    => Firetower::Plugins::Yamfire::CONSUMER_KEY,
          :secret => Firetower::Plugins::Yamfire::CONSUMER_SECRET
        },
        :access   => {
          :token  => config[:credentials][:token],
          :secret => config[:credentials][:secret]
        })
    end
  }
  fattr(:yammer_user_cache) {
    Hash.new do |hash, key|
      hash[key] = yammer_client.user(key)
    end
  }

  def yammer_username(user_id)
    yammer_user_cache[user_id].name
  end

  description "Yammer integration"
  mode "auth" do
    description "Authorize with Yammer"
    def run
      hl = HighLine.new
      yammer_config.transaction do |yammer_config|
        consumer = OAuth::Consumer.new(
          Firetower::Plugins::Yamfire::CONSUMER_KEY,
          Firetower::Plugins::Yamfire::CONSUMER_SECRET,
          :site               => "https://www.yammer.com",
          :request_token_path => "/oauth/request_token",
          :access_token_path  => "/oauth/access_token",
          :authorize_path     => "/oauth/authorize",
          :http_method        => :post,
          :signature_method   => "HMAC-SHA1")
        request_token = consumer.get_request_token
        hl.say "Please authorize Firetower to access your Yammer account"
        Launchy.open(request_token.authorize_url)
        callback_token = hl.ask "Enter the 4-digit code from the Yammer website"
        access_token =
          request_token.get_access_token(:oauth_verifier => callback_token)
        yammer_config[:credentials] = {
          :token  => access_token.token,
          :secret => access_token.secret,
        }
      end
    end
  end

  mode "messages" do
    description "Show the last few messages from Yammer"

    def run
      yammer_client.messages.each do |message|
        puts "#{yammer_username(message.sender_id)}: #{message.body.parsed}"
      end
    end
  end

  mode "post" do
    description "Post a status update to Yammer"
    argument "body"

    def run
      yammer_client.message(:post, :body => params["body"].value)
    end
  end
end
