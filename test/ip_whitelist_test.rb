require 'test_helper'

# A simple application that our middleware will pass whitelisted ips to.
SIMPLE_APP = Proc.new{[200, {'Content-Type' => 'text/plain'}, ['Success']]}

class IPWhitelistTestTest < Minitest::Test
  include DomainFirewall

  # For stubbing the #whitelist method.
  class DelegateStubber; def self.whitelist; end; end

  def setup
    @request = Rack::MockRequest.new(IPWhitelist.new(SIMPLE_APP,
      delegate: DelegateStubber))
  end

  def test_whitelisted_returning_true_value_allows_any_ip
    DelegateStubber.stub(:whitelist, true) do
      response = @request.get("/", "REMOTE_ADDR" => "1.1.1.1")
      assert_equal([200, 'Success'], [response.status, response.body])
    end
  end

  def test_whitelisted_ip
    DelegateStubber.stub(:whitelist, "1.1.1.1") do
      response = @request.get("/", "REMOTE_ADDR" => "1.1.1.1")
      assert_equal([200, 'Success'], [response.status, response.body])
    end
  end

  def test_non_whitelisted_ip_responds_in_403
    DelegateStubber.stub :whitelist, "1.1.1.1" do
      response = @request.get("/", "REMOTE_ADDR" => "0.0.0.0")
      assert_equal([403, nil, "Forbidden"],
                   [response.status, response.headers[:"Content-Type"],
                    response.body])
    end
  end

  def test_non_whitelisted_ip_redirects_given_a_url_option
    request = Rack::MockRequest.new(IPWhitelist.new(SIMPLE_APP,
                                               delegate: DelegateStubber, url: "/403.html"))
    DelegateStubber.stub :whitelist, "1.1.1.1" do
      response = request.get("/", "REMOTE_ADDR" => "0.0.0.0")
      assert_equal([303, "/403.html"], [response.status, response.location])
    end
  end

  def test_request_pass_through_when_request_url_option_url_the_same
    request = Rack::MockRequest.new(IPWhitelist.new(SIMPLE_APP,
      delegate: DelegateStubber, url: "/welcome.html"))
    DelegateStubber.stub :whitelist, "1.1.1.1" do
      response = request.get("/welcome.html", "REMOTE_ADDR" => "0.0.0.0")
      assert_equal([200, 'Success'], [response.status, response.body])
    end
  end

  def test_multible_whitelisted_ips
    DelegateStubber.stub(:whitelist, ["1.1.1.1","2.2.2.2"]) do
      response = @request.get("/", "REMOTE_ADDR" => "2.2.2.2" )
      assert_equal(200, response.status)
    end
  end

  def test_whitelisted_ips_containing_a_wildcard_in_first_position
    DelegateStubber.stub(:whitelist, "*.1.1.1") do
      response = @request.get("/", "REMOTE_ADDR" => "1.1.1.1")
      assert_equal(200, response.status)
    end
  end

  def test_whitelisted_ips_containing_a_wildcard_in_second_position
    DelegateStubber.stub(:whitelist, "1.*.1.1") do
      response = @request.get("/", "REMOTE_ADDR" => "1.1.1.1")
      assert_equal(200, response.status)
    end
  end

  def test_whitelisted_ips_containing_a_wildcard_in_third_position
    DelegateStubber.stub(:whitelist, "1.1.*.1") do
      response = @request.get("/", "REMOTE_ADDR" => "1.1.1.1")
      assert_equal(200, response.status)
    end
  end

  def test_whitelisted_ips_containing_a_wildcard_in_fourth_position
    DelegateStubber.stub(:whitelist, "1.1.1.*") do
      response = @request.get("/", "REMOTE_ADDR" => "1.1.1.1")
      assert_equal(200, response.status)
    end
  end

  def test_whitelisted_ips_containing_multiple_wildcards
    DelegateStubber.stub(:whitelist, "1.*.1.*") do
      response = @request.get("/", "REMOTE_ADDR" => "1.1.2.1")
      assert_equal(403, response.status)
    end
  end
end
