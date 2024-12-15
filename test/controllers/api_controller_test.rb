require "test_helper"

class ApiControllerTest < ActionDispatch::IntegrationTest
  test "should get small" do
    get api_small_url
    assert_response :success
  end
end
