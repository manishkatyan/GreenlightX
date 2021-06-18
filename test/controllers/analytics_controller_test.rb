require 'test_helper'

class AnalyticsControllerTest < ActionDispatch::IntegrationTest
  test "should get performance" do
    get analytics_performance_url
    assert_response :success
  end

end
