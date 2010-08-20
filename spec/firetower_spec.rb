require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[.. lib firetower plugins core notify_plugin])

describe Firetower do

  describe Firetower::Plugins::NotifyPlugin do
    context "given an ignore list" do
      let(:ignore_list) { ["avdi"] }
      let(:notifier) { stub("notifier") }
      let(:event) do 
        users = {123 => {"name" => "lake"}, 
          456 => {"name" => "avdi"}	}
        event = {"user_id" => 123, 
          "type" => "TextMessage"}
        event.stub_chain(:room, :account, :users).and_return(users)
        event
      end
      subject { Firetower::Plugins::NotifyPlugin.new(:ignore_list => ignore_list, :notifier => notifier) }

      it "should notify on message from unignored user" do
        notifier.should_receive(:call)
        subject.receive(nil,event)
      end
      it "should not notify on message from ignored user" do
        notifier.should_not_receive(:call)
        event["user_id"] = 456
        subject.receive(nil,event)
      end
    end
  end
end

