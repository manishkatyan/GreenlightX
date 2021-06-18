require 'test_helper'

class SubscriptionControllerTest < ActionDispatch::IntegrationTest
  test "should get stripe" do
    get subscription_stripe_url
    assert_response :success
  end

end
