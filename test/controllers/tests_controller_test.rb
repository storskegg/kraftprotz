require "test_helper"

class TestsControllerTest < ActionDispatch::IntegrationTest
  test "should get nietzsche" do
    get tests_nietzsche_url
    assert_response :success
  end
end
