require 'test_helper'

class DomainFirewallTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::DomainFirewall::VERSION
  end
end
