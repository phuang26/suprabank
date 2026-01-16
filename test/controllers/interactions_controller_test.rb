require "test_helper"

class InteractionsControllerTest < ActionController::TestCase
  #include Warden::Test::Helpers
  include Devise::Test::ControllerHelpers

  def setup
    @interaction = interactions :interaction_published
    @interaction_embargoed = interactions :interaction_one
    @user = users :user_one
    @molecule = molecules :molecule_one
    @host = molecules :molecule_two
  end

  def test_index
    get :index
    assert_response :success
    #assert_not_nil assigns(:interactions)
  end

  def test_new_when_logged_in_as_normal_user
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in @user
    get :new
    assert_response :success
  end

  def test_new_when_logged_out
    get :new
    assert_response :redirect
  end

  def test_create
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in @user
    session[:_csrf_token] = SecureRandom.base64(32)
    post :create, interaction: {molecule: @molecule, host: @host, binding_constant:1000, in_technique_type: "Fluorescence", method: "Direct", assay_type: "Direct Binding Assay" }, :in_technique =>{ lambda_em: 323}, authenticity_token: session[:_csrf_token]
    assert_response :success
  end

  def test_create_redirect
    session[:_csrf_token] = SecureRandom.base64(32)
    post :create, interaction: {molecule: @molecule, host: @host, binding_constant:1000, in_technique_type: "Fluorescence", method: "Direct", assay_type: "Direct Binding Assay" }, :in_technique =>{ lambda_em: 323}, authenticity_token: session[:_csrf_token]
    assert_response :redirect
  end
  #
  # def test_create
  #   assert_difference("Interaction.count") do
  #     post :create, interaction: {  }
  #   end
  #
  #   assert_redirected_to interaction_path(assigns(:interaction))
  # end

  def test_show
    get :show, id: @interaction
    assert_response :success
  end
  #
  def test_edit_redirect
    get :edit, id: @interaction
    assert_response :redirect
  end

  def test_edit_user_redirect
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in @user
    get :edit, id: @interaction
    assert_response :redirect
  end

  def test_edit_user
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in @user
    get :edit, id: @interaction_embargoed
    assert_response :success
  end

  def test_query_technique
    get :query_technique, term: "nmr"
    assert_response :success
    assert response.body == [["Nuclear Magnetic Resonance","NMR","N"]].to_json
  end

  def test_query_assay_type
    get :query_assay_type, term: "direct"
    assert_response :success
    assert response.body == [["Direct Binding Assay","DBA"]].to_json
  end
  #
  # def test_update
  #   put :update, id: interaction, interaction: {  }
  #   assert_redirected_to interaction_path(assigns(:interaction))
  # end
  #
  # def test_destroy
  #   assert_difference("Interaction.count", -1) do
  #     delete :destroy, id: interaction
  #   end
  #
  #   assert_redirected_to interactions_path
  # end
end
