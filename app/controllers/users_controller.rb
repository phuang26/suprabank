class UsersController < ApplicationController
  before_action :set_user, only: [:show, :interactions, :revisions, :datasets]
  before_action :set_meta_data
  before_action :authenticate_user!, except: [:query_orcid, :orcid_modal]


  include Orcid

  def index

  end

  def show
    @interactions = @user.interactions.active
    @groupinteractions = @user.groups.present? ?  @user.groups.first.group_interactions : nil
    @groupdatasets = @user.groups.present? ?  @user.groups.first.group_datasets : nil
    #UserMailer.welcome_email(@user).deliver!
  end

  def interactions
    authorize @user, :show?
    @qpublished = @user.interactions.published.ransack(params[:q])
    @published = @qpublished.result
    @interactions_published = Kaminari.paginate_array(@published).page(params[:page]).per(10)
  end

  def datasets
    authorize @user, :show?
    @datasets = @user.datasets
  end

  def orcid_modal
    array = query_name_array_from_name(params[:familyName],params[:givenName])
    #logger.debug "#{array}"
    #array = query_name_array_from_name("Sinn","Stephan")

    @orcid_results = array
    #logger.debug "#{@orcid_results}"
    respond_to do |format|
      format.html
      format.js
    end
  end


  def query_orcid

    array = query_name_array_from_name(params[:familyName],params[:givenName])
    @orcid_results = array
    logger.debug "#{array}"
    logger.debug "#{@orcid_results}"
    render json: array
  end

  def revisions
    authorize @user, :revisions?
    @interactions = InteractionPolicy::Moderator.new(@user, Interaction).resolve

    @qsubmitted = @interactions.submitted.ransack(params[:q])
    @submitted = @qsubmitted.result
    @interactions_submitted = Kaminari.paginate_array(@submitted).page(params[:page]).per(10)
    #
    # @qpending = @interactions.pending.ransack(params[:q])
    # @pending = @qpending.result
    @interactions_pending = @interactions.pending
    #
    # @qaccepted = @interactions.accepted.ransack(params[:q])
    # @accepted = @qaccepted.result
    @interactions_accepted = @interactions.accepted

  end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = User.find(params[:id])
      end

      def set_meta_data
        if @user.present?
          @title = "SupraBank - Users - #{@user.full_name}"
          #generic
          @meta_title = @title
          @meta_description = "User  #{@user.full_name} at SupraBank"
          @meta_image = @user.avatar.present? ? @user.avatar.url : "logo-production.png"
          #open graph facebook
          @meta_og_url = polymorphic_url(@user, host:"https://suprabank.org", :protocol => 'https' )
          # twitter card markup
        else
          @title = "SupraBank - Users"
          @meta_title = @title
          @meta_description = "Find the contributing users at SupraBank"
          @meta_image = "logo-production.png"
          @meta_og_url = "https://suprabank.org/users"
        end
      end


      # Never trust parameters from the scary internet, only allow the white list through.
      def user_params
        params.fetch(:user, {})
        params.require(:user).permit(:avatar, :givenName, :familyName, :png, :affiliation, :affiliationIdentifier)
      end
end
