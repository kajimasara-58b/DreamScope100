require "test_helper"

class Public::ComtactsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get public_comtacts_new_url
    assert_response :success
  end

  test "should get confirm" do
    get public_comtacts_confirm_url
    assert_response :success
  end

  test "should get done" do
    get public_comtacts_done_url
    assert_response :success
  end
end
