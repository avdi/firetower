require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[.. lib firetower plugins core notify_plugin])
require File.join(File.dirname(__FILE__), %w[.. lib firetower plugins core growl_plugin])

describe Firetower do

  shared_examples_for "Notifier Plugins" do
    
    context "given an ignore list" do
      let(:ignore_list) { ["avdi"] }
      let(:notifier) { stub("notifier") }
      let(:event) do 
        users = {123 => {"name" => "lake"}, 
          456 => {"name" => "avdi"}	}
        event = {"user_id" => 123, 
          "type" => "TextMessage"}
        event.stub_chain(:room, :account, :users).and_return(users)
        event.stub_chain(:room, :name).and_return('test room')

        event
      end

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

  describe Firetower::Plugins::NotifyPlugin do
    subject { Firetower::Plugins::NotifyPlugin.new(:ignore_list => ignore_list, :notifier => notifier) }
    it_should_behave_like "Notifier Plugins"
  end

  describe Firetower::Plugins::GrowlPlugin do
    subject { Firetower::Plugins::GrowlPlugin.new(:ignore_list => ignore_list, :notifier => notifier) }
    it_should_behave_like "Notifier Plugins"
  end

end

