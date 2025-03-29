require "test_helper"

class Public::ContactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # 各テストの前に有効なデータを用意
    @valid_params = { name: "Test User", email: "test@example.com", subject: "Test", message: "Hello" }
  end

  test "should get new" do
    get new_public_contact_path
    assert_response :success
    # 保存はしないのでエラーは出ないはず。不要な保存処理があれば削除
  end

  test "should get confirm" do
    # POSTリクエストでデータを送信してセッションに保存
    post confirm_public_contacts_path, params: { contact: @valid_params }
    # GETリクエストで確認画面をテスト
    get confirm_public_contacts_path
    assert_response :success
  end

  test "should get done" do
    # create を経由してデータを保存
    session[:contact_params] = @valid_params
    post create_public_contacts_path
    get done_public_contacts_path
    assert_response :success
  end
end
