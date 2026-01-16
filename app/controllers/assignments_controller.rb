class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update]
  before_action :require_same_user, only: [:edit, :update, :destroy]
  before_action :authenticate_user!, except: [:confirm_group]



  # GET /assignments/1
  # GET /assignments/1.json


  # GET /assignments/new


  def create

    @assignment = Assignment.new(assignment_params)
    respond_to do |format|
      if @assignment.save
        format.html { redirect_to @assignment, notice: 'Assignment was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def edit
    unless @assignment.group.present?
      @assignment.group = Group.new
    end
  end

  def update
    respond_to do |format|
      if @assignment.update(assignment_params)
        format.html { redirect_to @assignment.group, notice: 'Group was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def require_same_user

   if current_user != @assignment.user

     flash[:danger] = "You can only edit or delete your own assignments"

     redirect_to root_path
   end
  end


  def confirm_group
    assignment = Assignment.find_by_confirmation_token(params[:id])
    if assignment.present?
      assignment.activate_group
      if assignment.save
        flash[:success] = "User #{assignment.user.full_name} is now confirmed to be #{assignment.role} of group #{assignment.group.present? ? assignment.group.name : nil}"
      else
        flash[:danger] = "Something went wrong, contact the admin"
      end
    end
    redirect_to root_path
  end

  def decline_group
    assignment = Assignment.find_by_confirmation_token(params[:id])
    if assignment.present?
      assignment.rollback_group
      if assignment.save
        flash[:success] = "User #{assignment.user.full_name} remains in its former state."
      else
        flash[:danger] = "Something went wrong, contact the admin"
      end
    end
    redirect_to root_path
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = Assignment.find(params[:id])
    end


  def assignment_params
    params.fetch(:assignment, {})
    params.require(:assignment).permit(:id, :user_id, :group_id, group_attributes:[:affiliation, :affiliationIdentifier, :name,:city, :website,:department , :id, :_destroy, :country])

  end
end
