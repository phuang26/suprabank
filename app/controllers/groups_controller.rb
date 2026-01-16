class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :interactions, :datasets]
  before_action :set_meta_data
  before_action :authenticate_user!, except: [:query, :index, :query_affiliation]
  before_action :require_group_member, except: [:show, :index, :query, :query_affiliation]

  def index
  end

  def show
  end

  include Ror
  def query_affiliation
      array = query_ror_by_term(params[:term])
      render json: array
  end

  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_path, notice: 'Group was successfully destroyed.' }
    end
  end

  def query
      regexp = /#{params[:term]}/i; # case-insensitive regexp based on your string
      regexresult = Group.order(:name).where("name ILIKE ? OR affiliation ILIKE ? OR city ILIKE ?", "%#{params[:term]}%", "%#{params[:term]}%", "%#{params[:term]}%")
      result= regexresult.sort{|x, y| (x =~ regexp) <=> (y =~ regexp) }
      array = result.map{|n| [n.name , n.affiliation, n.department, n.city]}
      render json: array.sort_by{|word| word[1].length }[0..5]
  end


  def interactions
    @qpublished = @group.group_interactions.ransack(params[:q])
    @published = @qpublished.result
    @interactions_published = Kaminari.paginate_array(@published).page(params[:page]).per(10)
  end

  def datasets
    @datasets = @group.group_datasets
  end

  def index
    @groups = Group.all.order(updated_at: :desc)
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  def create

    @group = Group.new(group_params)
    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end
  private
    def require_group_member

     unless current_user.assignments.first.group == @group || current_user.admin?

       flash[:danger] = "You can only edit or delete your own group"

       redirect_to root_path

     end
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    def set_meta_data
      if @group.present?
        @title = "SupraBank - Groups - #{@group.name}"
        #generic
        @meta_title = @title
        @meta_description = "Group  #{@group.name} at SupraBank"
        @meta_image = "logo-production.png"
        #open graph facebook
        @meta_og_url = polymorphic_url(@group, host:"https://suprabank.org", :protocol => 'https' )
        # twitter card markup
      else
        @title = "SupraBank - Groups"
        @meta_title = @title
        @meta_description = "Find the contributing groups at SupraBank"
        @meta_image = "logo-production.png"
        @meta_og_url = "https://suprabank.org/groups"
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.fetch(:group, {})
      params.require(:group).permit(:name, :affiliation, :affiliationIdentifier, :department, :city, :website, :country)
    end
end
