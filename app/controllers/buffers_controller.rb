class BuffersController < ApplicationController
  before_action :set_buffer, only: [:show, :edit, :destroy, :update, :interactions]
  before_action :authenticate_user!, except: [:show, :index, :query, :listing, :dbsearch, :interactions, :media]
  before_action :set_meta_data

  def check_solvent(buffer_params)
    buffer_params["buffer_solvents_attributes"].each do |key, value|
      if value["solvent_name"].blank?
        value["solvent_name"]=nil
      end
    end
  end

  def interactions

  end

  def media
    
  end
  

  def update
    authorize @buffer
    check_solvent(buffer_params)
    respond_to do |format|
      if @buffer.update(buffer_params)
        format.html { redirect_to @buffer, notice: 'Buffer was successfully updated.' }
        format.json { render :show, status: :ok, location: @buffer }
      else
        format.html { render :edit }
        format.json { render json: @buffer.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @buffer
    @buffer.destroy
    respond_to do |format|
      format.html { redirect_to buffers_path, notice: 'Buffer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  def buffer_check
    regexp = /#{params[:term]}/i; # case-insensitive regexp based on your string
    regexresult = Buffer.order(:name).where("name ILIKE ? OR abbreviation ILIKE ?", "%#{params[:term]}%", "%#{params[:term]}%")
    result= regexresult.sort{|x, y| (x =~ regexp) <=> (y =~ regexp) }
    array = result.map{|n| [
      n.abbreviation ,
      n.name,
      n.conc.to_s,
      n.id,
      n.pH.to_s,
      n.solvents&.first&.display_name.to_s,
      n.additives&.first&.display_name.to_s,
      n.additives&.second&.display_name.to_s,
      n.additives&.third&.display_name.to_s,
      n.additives&.fourth&.display_name.to_s,
      ]}
    render json: array.sort_by{|word| word[1].length }
  end


  def query
      regexp = /#{params[:term]}/i; # case-insensitive regexp based on your string
      regexresult = Buffer.includes(:buffer_solvents, :solvents, :buffer_additives, :additives).order(:name).where("name ILIKE ? OR abbreviation ILIKE ?", "%#{params[:term]}%", "%#{params[:term]}%")
      result= regexresult.sort{|x, y| (x =~ regexp) <=> (y =~ regexp) }
      array = result.map{|n|
        [n.name ,
          n.abbreviation,
          n.pH, n.conc,
          n.updated_at.strftime("%-d. %b %Y"),
          n.solvents.first.present? ? n.solvents.first.preferred_abbreviation : "not given",
          n.buffer_solvents.first.present? ? n.buffer_solvents.first.volume_percent : "not given",
          n.additives.first.present? ? n.additives.first.preferred_abbreviation : "not given",
          n.buffer_additives.first.present? ? n.buffer_additives.first.concentration : "not given",
          n.solvents.second.present? ? n.solvents.second.preferred_abbreviation : "not given",
          n.buffer_solvents.second.present? ? n.buffer_solvents.second.volume_percent : "not given",
          n.additives.second.present? ? n.additives.second.preferred_abbreviation : "not given",
          n.buffer_additives.second.present? ? n.buffer_additives.second.concentration : "not given",
          n.solvents.third.present? ? n.solvents.third.preferred_abbreviation : "not given",
          n.buffer_solvents.third.present? ? n.buffer_solvents.third.volume_percent : "not given",
          n.additives.third.present? ? n.additives.third.preferred_abbreviation : "not given",
          n.buffer_additives.third.present? ? n.buffer_additives.third.concentration : "not given",
          n.additives.fourth.present? ? n.additives.fourth.preferred_abbreviation : "not given",
          n.buffer_additives.fourth.present? ? n.buffer_additives.fourth.concentration : "not given",
          n.sourceofconcentration.present? ? n.sourceofconcentration : "not given"]}
      array.each do |a|
        a.map!{|e| e.present? ? e : "not given" }
      end
      render json: array.sort_by{|word| word[1].length }[0..20]
  end

  def listing
    @buffers = Buffer.all.order(updated_at: :desc)
  end

  def dbsearch
      if params[:search_param].blank? & params[:pH_param].blank? & params[:conc_param].blank?
        flash.now[:warning] = 'You need to put some content.'
        render partial: 'dbresult'
      else
        @buffers = Buffer.dbsearch(params[:search_param],params[:pH_param],params[:conc_param])
        if @buffers.present?
          render partial: 'dbresult'
        else
          flash.now[:warning] = 'Nothing found in the database Buffers' if @buffers.blank?
          render partial: 'dbresult'
        end
      end
  end


  def index
    
  end

  def show
  end


  def new
    @buffer = Buffer.new

    4.times{@buffer.buffer_additives.build}
    3.times{@buffer.buffer_solvents.build}

  end


  def edit
    authorize @buffer, :update?
  end

  def create

    @buffer = Buffer.new(buffer_params)
    @buffer.user = current_user
    respond_to do |format|
      if @buffer.save
        format.html { redirect_to @buffer, notice: 'Buffer was successfully created.' }
        format.json { render :show, status: :created, location: @buffer }
      else
        format.html { render :new }
        format.json { render json: @buffer.errors, status: :unprocessable_entity }
        flash.now[:alert] = 'Buffer could not be created. The name needs to be unique. Please compare to the table below and rename your buffer by adding e.g. an "A" at the end of the name.'
      end
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_buffer
      @buffer = Buffer.find(params[:id])
    end

    def set_meta_data
      if @buffer.present?
        @title = "SupraBank - Buffers - #{@buffer.name}"
        #generic
        @meta_title = @title
        @meta_description = "Buffer  #{@buffer.name.present? ? @buffer.name : "no name present"} at SupraBank"
        @meta_image = "logo-production.png"
        #open graph facebook
        @meta_og_url = polymorphic_url(@buffer, host:"https://suprabank.org", :protocol => 'https' )
        # twitter card markup
      else
        @title = "SupraBank - Buffers"
        @meta_title = @title
        @meta_description = "Find buffers at SupraBank"
        @meta_image = "logo-production.png"
        @meta_og_url = "https://suprabank.org/buffers"
      end
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def buffer_params
      params.fetch(:buffer, {})
      params.require(:buffer).permit(
        :conc,
        :pH,
        :abbreviation,
        :name,
        :sourceofconcentration,
        :buffer_solvents,
        :buffer_additives,
        buffer_solvents_attributes: [:id, :buffer_id, :volume_percent, :solvent_id, :solvent_name, :second_solvent_name, :third_solvent_name, :fourth_solvent_name],
        solvents_attributes: [:display_name, :id, :_destroy],
        additives_attributes: [:display_name, :id, :_destroy],
        buffer_additives_attributes: [:id, :buffer_id, :concentration, :additive_id, :additive_name, :second_additive_name, :third_additive_name, :fourth_additive_name])
      #params.require(:molecule).permit(:inchikey, :names, :cid, :svg)
    end
end
