require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[.. lib firetower plugins core notify_plugin])
require File.join(File.dirname(__FILE__), %w[.. lib firetower plugins core growl_plugin])

describe Firetower do

  describe Firetower::Accounts do
    subject {
      it = Object.new; it.extend(Firetower::Accounts); it
    }

    it "should be able to add a new account" do
      expect { subject.account "example.com", "XXXX" }.
        to change{subject.accounts.size}.by(1)
    end

    it "should remember account settings" do
      subject.account "example.com", "XXXX", :ssl => true
      subject.accounts.values.last.subdomain.should == "example.com"
      subject.accounts.values.last.token.should == "XXXX"
      subject.accounts.values.last.should be_ssl
    end

    it "should fire :new_account when an account is added" do
      listener = Firetower::Session::Listener.new
      listener.should_receive(:new_account).with("example.com", "XYZZY", :foo => :bar)
      subject.add_listener(listener)
      subject.account "example.com", "XYZZY", :foo => :bar
    end

    context "given an account fetcher" do
      let(:room1) { stub("Room 1")}
      let(:account) {stub("Account", :rooms => {"room1" => room1})}
      before do
        subject.account_fetcher = lambda { account }
        subject.account "example.com", "XXXX"
      end

      it "should be able to fetch rooms" do
        subject.find_room("example.com", "room1").should equal(room1)
      end
    end
  end

  describe Firetower::Rooms do
    subject {
      it = Object.new; it.extend(Firetower::Rooms); it
    }

    context "given an account" do
      let(:room1) { stub("Room 1") }

      before do
        subject.stub!(:find_room).with("example.com", "room1").
          and_return(room1)
      end

      it "should be able to add a room subscription" do
        expect { subject.join_room "example.com", "room1" }.
          to change{subject.subscribed_rooms.size}.by(1)
      end
    end
  end

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
      it "should notify on unignored user join" do
        notifier.should_receive(:call)
        event['type'] = 'EnterMessage'
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

