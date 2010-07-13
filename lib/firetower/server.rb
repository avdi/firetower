module Firetower
  class Server
    attr_reader :session, :log_path, :pid_path

    def initialize(session, options={})
      @session  = session
      @log_path = Pathname(options.fetch(:log_path))
      @pid_path = Pathname(options.fetch(:pid_path))
      @logger   = options.fetch(:logger) {
        ::Logger.new(@log_path, 4, 1024000)
      }
    end

    def run
      trap('INT') do
        @logger.info "Received INT; shutting down."
        EventMachine.stop_event_loop
        @pid_path.unlink if @pid_path.exist?
      end
      EventMachine::run do
        @logger.info "Firetower is starting up"
        open(@pid_path, 'w+') do |pid_file|
          pid_file.puts $$
        end
        @session.subscribed_rooms.each do |room|
          subscribe_to_room(room)
        end
      end
      @logger.info "Finished processing events; closing session"
      session.close!
      @logger.info "Session closed"
    end

    def subscribe_to_room(room)
      @logger.info "Subscribing to #{room}"

      room.account.join!(room.name)

      stream = Twitter::JSONStream.connect(
        :path => "/room/#{room.id}/live.json",
        :host => 'streaming.campfirenow.com',
        :auth => "#{room.account.token}:x")

      stream.each_item do |event|
        @logger.info "Processing event:\n  #{event}"
        event = JSON.parse(event)

        (class << event; self; end).send(:define_method, :room){room}
        session.execute_hook(:receive, session, event)
      end

      stream.on_error do |message|
        error = RuntimeError.new(message)
        @logger.error error.message
        session.execute_hook(:error, error)
      end

      stream.on_max_reconnects do |timeout, retries|
        @logger.error "Unable to connect after #{retries} attempts"
        session.execute_hook(:error, session,
          "Unable to connect after #{retries} attempts")
        stop_event_loop
      end
    end

  end
end
