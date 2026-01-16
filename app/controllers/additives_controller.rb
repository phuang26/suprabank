class AdditivesController < ApplicationController
  before_action :set_additive, only: [:show, :edit, :update, :destroy, :interactions]
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
    if params[:additive].blank?
      flash.now[:warning] = 'You need to put some search string'
      render partial: 'dbresult'
    else
      @additive = Additive.new
      @additive.preliminary_data params[:additive]
      if @additive.additive_presence(@additive.cid)
        @additive=Additive.find_by_cid(@additive.cid)
        flash.now[:success] = "The additive exists already in the SupraBank."
        render partial: 'additives/found_result'
      elsif @additive.cid.present?
        flash.now[:success] = "The additive is present on PubChem, but not yet at SupraBank, you can retrieve it!"
        render partial: "additives/preliminary_result"
      else
        flash.now[:danger] = 'Unfortunately, we could not find anything on PubChem. Please first check directly on PubChem for the name and the CID and use here afterwards the "Use CID Instead" option on the right.'
        render partial: "additives/nothing_found"
      end
    end
  end



  def pubchem_full_record
    @additive = Additive.new(cid: params[:cid])
    unless @additive.additive_presence(@additive.cid)
      @additive.full_data params[:cid]
      @additive.clip_png
      @additive.add_names
      @additive.add_cas
      @additive.save
      @message = "Your additive was successfully added to the SupraBank"
    else
      @additive = Additive.find_by_cid(params[:cid])
      @message = "The additive exists already in the SupraBank"
    end

    respond_to do |format|
      format.js
    end
  end

  def query
      regexp = /#{params[:term]}/i; # case-insensitive regexp based on your string
      regexresult = Additive.select(:preferred_abbreviation, :display_name, :png_url, :id).order(:display_name).where("display_name ILIKE ? OR preferred_abbreviation ILIKE ?", "%#{params[:term]}%", "%#{params[:term]}%")
      result= regexresult.sort{|x, y| (x =~ regexp) <=> (y =~ regexp) }
      array = result.map{|n| [n.preferred_abbreviation , n.display_name, n.png_url, n.id]}
      render json: array.sort_by{|word| word[1].length }[0..5]
  end

  def edit
    authorize @additive
  end

  def update
    respond_to do |format|
      if @additive.update(additive_params)
        format.html { redirect_to @additive, notice: 'Additive was successfully updated.' }
        format.json { render :show, status: :ok, location: @additive }
      else
        format.html { render :edit }
        format.json { render json: @additive.errors, status: :unprocessable_entity }
      end
    end
  end

  def search
    if params[:additive].blank?
      flash.now[:warning] = 'You need to put some search string'
    else
      @additive = Additive.new_from_name(params[:additive])
      if @additive.present?
        if @additive == "exist"
          @additive = Additive.dbsearch(params[:additive]).first
          flash.now[:success] = 'Additive is already present in the SupraBank'
        else
          flash.now[:success] = 'Additive was added successfully to the SupraBank'
        end
      else
        flash.now[:warning] = 'Nothing found by Name at PubChem. You may try with the CAS number?'
      end
    end
    render partial: 'additives/result'
  end

  def cid_request
    if params[:cidadditive].blank?
      flash.now[:warning] = 'You need to put the PubChem Compound ID (CID)'
      render partial: 'dbresult'
    else
      @additive = Additive.new
      @additive.preliminary_cid_data params[:cidadditive]
      unless @additive.additive_presence(@additive.cid)
        render partial: "additives/preliminary_result"
      else
        @additive=Additive.find_by_cid(@additive.cid)
        flash.now[:success] = "The additive exists already in the SupraBank"
        render partial: 'additives/result'
      end
    end
  end


  def dbsearch
      if params[:search_param].blank?
        flash.now[:warning] = 'You need to put some content'
        render partial: 'dbresult'
      else
        @additives = Additive.dbsearch(params[:search_param])
        if @additives.present?
          render partial: 'dbresult'
        else
          flash.now[:warning] = 'Nothing found in the database Additives' if @additives.blank?
          render partial: 'dbresult'
        end
      end
  end





  def index
    @additives = Additive.all
  end

  # GET /additives/1
  # GET /additives/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_additive
      @additive = Additive.find(params[:id])
    end

    def set_meta_data
      if @additive.present?
        @title = "SupraBank - Additives - #{@additive.display_name}"
        #generic
        @meta_title = @title
        @meta_description = "Additive  #{@additive.display_name.present? ? @additive.display_name : "no name present"} at SupraBank"
        @meta_image = @additive.png.present? ? @additive.png.url : "logo-production.png"
        #open graph facebook
        @meta_og_url = polymorphic_url(@additive, host:"https://suprabank.org", :protocol => 'https' )
        # twitter card markup
      else
        @title = "SupraBank - Additives"
        @meta_title = @title
        @meta_description = "Find additives at SupraBank"
        @meta_image = "logo-production.png"
        @meta_og_url = "https://suprabank.org/additives"
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def additive_params
      params.fetch(:additive, {})
      params.require(:additive).permit(:display_name, :names, :cid, :svg, :preferred_abbreviation, :cas, :png, :png_file_name)
    end
end
