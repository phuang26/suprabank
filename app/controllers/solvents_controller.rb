class SolventsController < ApplicationController
  before_action :set_solvent, only: [:show, :edit, :update, :destroy, :interactions]
  before_action :authenticate_user!, except: [:show, :index, :dbsearch, :query, :interactions]
  before_action :set_meta_data

  def interactions

  end

  def pubchem_help
    respond_to do |format|
      format.html {}
      format.js {notice = 'You need to put some search string'}
    end
  end


  def pubchem_request
    if params[:solvent].blank?
      flash.now[:warning] = 'You need to put some search string'
      render partial: 'dbresult'
    else
      @solvent = Solvent.new
      @solvent.preliminary_data params[:solvent]
      if @solvent.solvent_presence(@solvent.cid)
        @solvent=Solvent.find_by_cid(@solvent.cid)
        flash.now[:success] = "The solvent exists already in the SupraBank."
        render partial: 'solvents/found_result'
      elsif @solvent.cid.present?
        flash.now[:success] = "The solvent is present on PubChem, but not yet at SupraBank, you can retrieve it!"
        render partial: "solvents/preliminary_result"
      else
        flash.now[:danger] = 'Unfortunately, we could not find anything on PubChem. Please first check directly on PubChem for the name and the CID and use here afterwards the "Use CID Instead" option on the right.'
        render partial: "solvents/nothing_found"
      end
    end
  end

  def pubchem_full_record
    @solvent = Solvent.new(cid: params[:cid])
    unless @solvent.solvent_presence(@solvent.cid)
      @solvent.full_data params[:cid]
      @solvent.clip_png
      @solvent.add_names
      @solvent.add_cas
      @solvent.save
      @message = "Your solvent was successfully added to the SupraBank"
    else
      @solvent = Solvent.find_by_cid(params[:cid])
      @message = "The solvent exists already in the SupraBank"
    end

    respond_to do |format|
      format.js
    end
  end

  def query
      regexp = /#{params[:term]}/i; # case-insensitive regexp based on your string
      regexresult = Solvent.select(:preferred_abbreviation, :display_name, :molecular_weight, :png_url).order(:display_name).where("display_name ILIKE ? OR preferred_abbreviation ILIKE ?", "%#{params[:term]}%", "%#{params[:term]}%")
      result= regexresult.sort{|x, y| (x =~ regexp) <=> (y =~ regexp) }
      array = result.map{|n| [n.preferred_abbreviation , n.display_name, n.png_url.present? ? n.png_url : "/images/thumb/missing.png"]}
      render json: array.sort_by{|word| word[1].length }[0..5]
  end

  def edit
    authorize @solvent
  end

  def update
    respond_to do |format|
      if @solvent.update(solvent_params)
        format.html { redirect_to @solvent, notice: 'Solvent was successfully updated.' }
        format.json { render :show, status: :ok, location: @solvent }
      else
        format.html { render :edit }
        format.json { render json: @solvent.errors, status: :unprocessable_entity }
      end
    end
  end

  def search
    if params[:solvent].blank?
      flash.now[:warning] = 'You need to put some search string'
    else
      @solvent = Solvent.new_from_name(params[:solvent])
      if @solvent.present?
        if @solvent == "exist"
          @solvent = Solvent.dbsearch(params[:solvent]).first
          flash.now[:success] = 'Solvent is already present in the SupraBank'
        else
          flash.now[:success] = 'Solvent was added successfully to the SupraBank'
        end
      else
        flash.now[:warning] = 'Nothing found by Name at PubChem. You may try with the CAS number?'
      end
    end
    render partial: 'solvents/result'
  end

  def cid_request
    if params[:cidsolvent].blank?
      flash.now[:warning] = 'You need to put the PubChem Compound ID (CID)'
      render partial: 'dbresult'
    else
      @solvent = Solvent.new
      @solvent.preliminary_cid_data params[:cidsolvent]
      unless @solvent.solvent_presence(@solvent.cid)
        render partial: "solvents/preliminary_result"
      else
        @solvent=Solvent.find_by_cid(@solvent.cid)
        flash.now[:success] = "The solvent exists already in the SupraBank"
        render partial: 'solvents/result'
      end
    end
  end

  def dbsearch
      if params[:search_param].blank?
        flash.now[:warning] = 'You need to put some content'
        render partial: 'dbresult'
      else
        @solvents = Solvent.dbsearch(params[:search_param])
        if @solvents.present?
          render partial: 'dbresult'
        else
          flash.now[:warning] = 'Nothing found in the database Solvents' if @solvents.blank?
          render partial: 'dbresult'
        end
      end
  end


  def index
    @solvents = Solvent.all
  end

  # GET /solvents/1
  # GET /solvents/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_solvent
      @solvent = Solvent.find(params[:id])
      @interactions = @solvent.interactions.active.first
    end

    def set_meta_data
      if @solvent.present?
        @title = "SupraBank - Solvents - #{@solvent.display_name}"
        #generic
        @meta_title = @title
        @meta_description = "Solvent  #{@solvent.display_name.present? ? @solvent.display_name : "no name present"} at SupraBank"
        @meta_image = @solvent.png.present? ? @solvent.png.url : "logo-production.png"
        #open graph facebook
        @meta_og_url = polymorphic_url(@solvent, host:"https://suprabank.org", :protocol => 'https' )
        # twitter card markup
      else
        @title = "SupraBank - Solvents"
        @meta_title = @title
        @meta_description = "Find solvents at SupraBank"
        @meta_image = "logo-production.png"
        @meta_og_url = "https://suprabank.org/solvents"
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def solvent_params
      params.fetch(:solvent, {})
      params.require(:solvent).permit(:display_name, :names, :cid, :svg, :preferred_abbreviation, :cas, :png, :png_file_name)
    end
end
