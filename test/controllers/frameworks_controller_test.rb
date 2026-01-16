require "test_helper"

class FrameworksControllerTest < ActionController::TestCase
  def framework
    @framework ||= frameworks :one
  end

  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns(:frameworks)
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create
    assert_difference("Framework.count") do
      post :create, framework: {  }
    end

    assert_redirected_to framework_path(assigns(:framework))
  end

  def test_show
    get :show, id: framework
    assert_response :success
  end

  def test_edit
    get :edit, id: framework
    assert_response :success
  end

  def test_update
    put :update, id: framework, framework: {  }
    assert_redirected_to framework_path(assigns(:framework))
  end

  def test_destroy
    assert_difference("Framework.count", -1) do
      delete :destroy, id: framework
    end

    assert_redirected_to frameworks_path
  end
end
