require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  test "should get change_verification" do
    get admin_change_verification_url
    assert_response :success
  end

end
