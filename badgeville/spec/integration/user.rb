require 'badgeville'
require 'rspec'
require 'ruby-debug'
require 'fakeweb'
require 'factory_girl'
require 'ruby-debug'
require 'factories.rb'


module Badgeville

  Config.conf(:site => 'http://staging.badgeville.com/', :api_key => '007857cd4fb9f360e120589c34fea080')

  FakeWeb.allow_net_connect = false # Requests to a URI you haven’t registered with #register_uri, a NetConnectNotAllowedError will be raised

  describe 'Create a new user' do
    before do
  
      @path = "/api/berlin/007857cd4fb9f360e120589c34fea080/users.json"
      @port = "80"
  
      @user = {
        :email => 'visitor@emailserver.com',
        :name => 'visitor_username',
        :network_id => '4d5dc61ed0c0b32b79000001',
        :password => 'visitor_password'
      }
  
      FakeWeb.register_uri(
        :post,
        "http://" + BaseResource.site.host + ":" + @port + @path,
        {:body => "{\"user\":" + @user.to_json + "}", :status => [201, "Created"]}
      )
    end
  
    it "should make the correct http request" do
      # Mocks
      mock_http = Net::HTTP.new(BaseResource.site.host, @port)
      mock_http_ok = mock_http.send(:post, @path, {"Accept"=>"application/json"})
      # Expectations
      mock_http.should_receive(:send)
        .with(:post, @path, "{\"user\":" + @user.to_json + "}", {"Content-Type"=>"application/json"})
        .and_return(mock_http_ok)
      Net::HTTP.should_receive(:new).with(BaseResource.site.host, Integer(@port)).and_return(mock_http)
  
      User.new(@user).save()
    end
  end
  
  describe 'Find a user' do
    before do
      @mock_user = {
        :_id => "4f05ef5ea768651b3500009f",
        :name => "visitor_username",
        :created_at => '2012-01-05T10:43:42-08:00',
        :email => "revised_visitor@emailserver.com",  
        :prefix_options => {},
        :persisted => true
      }
      @path = "/api/berlin/007857cd4fb9f360e120589c34fea080/users/" + @mock_user[:_id] + ".json"
      @port = "80"
      # Result for find
      FakeWeb.register_uri(
        :get,
        "http://" + BaseResource.site.host + ":" + @port + @path,
        {:body => "{\"user\":" + @mock_user.to_json + "}", :status => [200, "Ok"]}
      )
    end
  
    it "should make the correct http request" do
      # Mocks
      mock_http = Net::HTTP.new(BaseResource.site.host, @port)
      mock_http_ok = mock_http.send(:get, @path, {"Accept"=>"application/json"})
      # Expectations
      Net::HTTP.should_receive(:new).with(BaseResource.site.host, Integer(@port)).and_return(mock_http)
      mock_http.should_receive(:send).with(:get, @path, {"Accept"=>"application/json"}).and_return(mock_http_ok)
      # Execute
      User.find(@mock_user[:_id])
    end
  end
  
  describe 'Update a user' do
    before do
      @user = {
        :_id => "4f05ef5ea768651b3500009f",
        :created_at => '2012-01-05T10:43:42-08:00',
        :email => "revised_visitor@emailserver.com",  
        :name => "visitor_username"
      }
      
      @path = "/api/berlin/007857cd4fb9f360e120589c34fea080/users/" + @user[:_id] + ".json"
      @port = "80"
  
      FakeWeb.register_uri(
        :put,
        "http://" + BaseResource.site.host + ":" + @port + @path,
        {:body => "{\"user\":" + @user.to_json + "}", :status => [200, "Ok"]}
      )
    end
  
    it "should make the correct http request" do
      # Mocks
      mock_http = Net::HTTP.new(BaseResource.site.host, @port)
      mock_http_ok = mock_http.send(:put, @path, {"Accept"=>"application/json"})
      # Expectations
      mock_http.should_receive(:send)
        .with(:put, @path, "{\"user\":" + @user.to_json + "}", {"Content-Type"=>"application/json"})
        .and_return(mock_http_ok)
      Net::HTTP.should_receive(:new).with(BaseResource.site.host, Integer(@port)).and_return(mock_http)
      User.new(@user, true).save()
    end
  end
end