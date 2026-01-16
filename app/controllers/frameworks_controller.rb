class FrameworksController < ApplicationController
  before_action :set_framework, only: [:show, :edit, :update, :destroy, :preview]
  before_action :authenticate_user!

  def query
    regexp = /#{params[:term]}/i; # case-insensitive regexp based on your string
    #.select(:code, :name, :molecular_weight, :png_url)
    regexresult = Framework.order(:code).where("code ILIKE ? OR name ILIKE ?", "%#{params[:term]}%", "%#{params[:term]}%")
    result= regexresult.sort{|x, y| (x =~ regexp) <=> (y =~ regexp) }
    array = result.map{|n| [n.code , n.name, n.png_url, n.iza_url, n.id]}
    render json: array.sort_by{|word| word[1].length }[0..5]
  end

  def preview
    
  end
  

  # GET /frameworks
  # GET /frameworks.json
  def index
    authorize Framework, :editor_or_admin?
    @frameworks = Framework.all
  end

  # GET /frameworks/1
  # GET /frameworks/1.json
  def show
    authorize Framework, :editor_or_admin?
  end

  # GET /frameworks/new
  def new
    authorize Framework, :editor_or_admin?
    @framework = Framework.new
  end

  # GET /frameworks/1/edit
  def edit
    authorize Framework, :editor_or_admin?
  end

  # POST /frameworks
  # POST /frameworks.json
  def create
    @framework = Framework.new(framework_params)
    authorize @framework, :editor_or_admin?
    @framework.user = current_user
    @framework.ring_sizes = framework_params[:ring_sizes].split(' ')
    respond_to do |format|
      if @framework.save
        format.html { redirect_to @framework, notice: 'Framework was successfully created.' }
        format.json { render :show, status: :created, location: @framework }
      else
        format.html { render :new }
        format.json { render json: @framework.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /frameworks/1
  # PATCH/PUT /frameworks/1.json
  def update
    authorize @framework, :editor_or_admin?
    respond_to do |format|
      if @framework.update(framework_params)
        @framework.ring_sizes = framework_params[:ring_sizes].split(' ')
        @framework.save
        format.html { redirect_to @framework, notice: 'Framework was successfully updated.' }
        format.json { render :show, status: :ok, location: @framework }
      else
        format.html { render :edit }
        format.json { render json: @framework.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /frameworks/1
  # DELETE /frameworks/1.json
  def destroy
    authorize @framework, :editor_or_admin?
    @framework.destroy
    respond_to do |format|
      format.html { redirect_to frameworks_url, notice: 'Framework was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_framework
      @framework = Framework.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def framework_params
      params.fetch(:framework, {})
      params.require(:framework).permit(:name,
        :code,
        :crystal_system,
        :space_group,
        :unit_cell_a,
        :unit_cell_b,
        :unit_cell_c,
        :unit_cell_alpha,
        :unit_cell_beta,
        :unit_cell_gamma,
        :volume,
        :rdls,
        :framework_density,
        :topological_density,
        :topological_density_10,
        :ring_sizes,
        :channel_dimensionality,
        :max_d_sphere_included,
        :max_d_sphere_diffuse_a,
        :max_d_sphere_diffuse_b,
        :max_d_sphere_diffuse_c,
        :accessible_volume,
        :png, :png_file_name)
    end
end
