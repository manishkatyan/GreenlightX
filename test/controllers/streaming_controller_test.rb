require 'test_helper'

class StreamingControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get streaming_create_url
    assert_response :success
  end

end
