require "test_helper"

class RootControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_index_url
    assert_response :success
  end
end

def root_index_url
  root_path
end
