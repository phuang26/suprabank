class InteractionsController < ApplicationController
  include ActionView::Helpers::NumberHelper # <-
  include Technology
  include Colors
  before_action :set_interaction, only: [:show, :edit, :update, :destroy, :hg_sim_data, :solvent_check, :citation_export, :reviewer_comments, :accident, :self_acceptance]
  before_action :set_meta_data
  before_action :authenticate_user!, except: [:show, :citation_export, :index, :intsearch, :advanced_search, :advsearch, :dbsearch, :hg_sim_data, :query_technique, :query_assay_type]

  def dataset_update
      Interaction.update_all({},{id: params[:interaction_ids]})
  end


    # GET /interactions
    # GET /interactions.json

  def self_acceptance
    @dataset = @interaction.dataset
    authorize @dataset, :self_revision_interaction?
    @interaction.update(revision: 'submitted')
    flash[:success] = "Your interaction was revised by yourself and is currently 'submitted'. When all interactions are revised you may accept them from within the dataset."
    redirect_to  dataset_path(@dataset)
  end
  


    def advanced_search
      @interactions = nil
      @techniques=Technique.all
      @q = Interaction.published.ransack(query_params)
      @selection = @q.result
      if query_params.present?
        @interactions = Kaminari.paginate_array(@selection).page(params[:page]).per(10)
      end
      respond_to do |format|
        format.html
        format.js
      end
    end

    def query_itc_instruments
        regexp = /#{params[:term]}/i; # case-insensitive regexp based on your string
        regexresult = ItcInstrument.order(:name).where("name ILIKE ? OR alternative_name ILIKE ? OR brand ILIKE ?", "%#{params[:term]}%", "%#{params[:term]}%", "%#{params[:term]}%")
        result= regexresult.sort{|x, y| (x =~ regexp) <=> (y =~ regexp) }
        array = result.map{|n| [n.name , n.alternative_name, n.brand, n.cell_volume, n.syringe_volume]}
        render json: array
        #render json: result.to_json
    end


    def query_technique
          regexp = /#{params[:term]}/i; # case-insensitive regexp based on your string
          t1=Technique.where("names && ?", "{#{params[:term].upcase}}")
          t2=Technique.order(:names).where("names[1] ILIKE ?", "%#{params[:term]}%")
          regexresult = (t1+t2).uniq
          #regexresult = Technique.order(:names).where("names ILIKE ? ", "%#{params[:term]}%")
          result= regexresult.sort{|x, y| (x =~ regexp) <=> (y =~ regexp) }
          array = result.map{|n| [n.names[0], n.names[1], n.names[2]]}
          render json: array.sort_by{|word| word[1].length }
    end

    def query_assay_type
          regexp = /#{params[:term]}/i; # case-insensitive regexp based on your string
          a1=AssayType.where("names && ?", "{#{params[:term].upcase}}")
          a2=AssayType.order(:names).where("names[1] ILIKE ?", "%#{params[:term]}%")
          regexresult = (a1+a2).uniq
          result= regexresult.sort{|x, y| (x =~ regexp) <=> (y =~ regexp) }
          array = result.map{|n| [n.names[0], n.names[1]]}
          render json: array.sort_by{|word| word[1].length }
    end



    def dbsearch
      if params[:search_param].blank?
        flash.now[:warning] = 'You need to put some content'
        render partial: 'dbresult'
      else
        @interactions = Interaction.includes(:molecule).order(updated_at: :desc).dbsearch(params[:search_param])
        if @interactions.present?
          #@interactions=@interactions[0..199]
          render partial: 'dbresult'
        else
          input = params[:search_param]
          response = input[0..(input.length/2)]
          flash.now[:warning] = "No Interaction was found, please use wildcards like <strong>#{response}%</strong>".html_safe if @interactions.blank?

          render partial: 'dbresult'
        end
      end
    end

    # def advsearch
    #   if params[:molecule_param].blank? & params[:mol_tags_param].blank? & params[:host_param].blank? & params[:host_tags_param].blank? & params[:binding_param].blank? & params[:binding_to_param].blank? & params[:technique_param].blank? & params[:assay_type_param].blank? & params[:supplement_param].blank? & params[:doi_param].blank? & params[:author_param].blank? & params[:year_param].blank? & params[:solvent_param].blank? & params[:buffer_param].blank? & params[:pH_param].blank? & params[:pH_to_param].blank? & params[:temperature_param].blank? & params[:temperature_to_param].blank?
    #     flash.now[:warning] = 'You need to put some content'
    #     render partial: 'advresult'
    #   else
    #     @interactions = Interaction.advsearch(params[:molecule_param],params[:mol_tags_param],params[:host_param],params[:host_tags_param],params[:binding_param],params[:binding_to_param],params[:technique_param],params[:assay_type_param],params[:supplement_param], params[:doi_param], params[:author_param], params[:year_param], params[:solvent_param], params[:buffer_param], params[:pH_param], params[:pH_to_param], params[:temperature_param], params[:temperature_to_param], params[:molecule_exclusive_param], params[:host_exclusive_param], params[:host_or_param])
    #     if @interactions.present?
    #       #@interactions=@interactions[0..199]
    #       render partial: 'advresult'
    #     else
    #       #input = params[:search_param]
    #       #response = input[0..(input.length/2)]
    #       flash.now[:warning] = "No Interaction was found." if @interactions.blank?
    #       render partial: 'advresult'
    #     end
    #   end
    # end

    

    def pogresearch
        if params[:search_param].blank?
          flash.now[:warning] = 'You need to put some content'
          render partial: 'pgresult'
        else
          @interactions = Interaction.search_by_doi(params[:search_param])
          if @interactions.present?
            render partial: 'pgresult'
          else
            flash.now[:warning] = 'Nothing found in the database Molecules' if @molecules.blank?
            render partial: 'pgresult'
          end
        end
    end

    def solvent_check
      if true
        render "hello"
      end
    end

    def hg_sim_data
      base = (0..100).to_a.map{|element| element*0.01}
      c1 = 20./@interaction.binding_constant
      c2 = 2*c1
      ka = @interaction.binding_constant
      x = base.map{|element| element*c2}
      y = x.map{|element| (c1+element+1/ka)/2-Math.sqrt(((c1+element+1/ka)*(c1+element+1/ka))/4-c1*element)}

      sol = x.zip(y).to_h
      xy_data = Hash["jsonarray",sol.map{|x,y| {"x" => x, "y" => y}}].to_json
      #xy_data for chart.js and sol for chartkick

      render json: xy_data
    end


    def duplicate
      @interaction = Interaction.duplicate(params[:id], current_user, params[:dataset_id])
     respond_to do |format|
        if @interaction.save
          format.html { redirect_to edit_interaction_path(@interaction), notice: 'Item was successfully created. Please make sure to edit it now. Avoid simple duplicates.' }
        else
          format.html {  redirect_to Interaction.find(params[:id]), notice: 'ERROR: Item can\'t be cloned.'}
        end
      end
    end


    def index
      @q = Interaction.includes(:molecule, :host, :in_technique, :buffer, :user, :indicator, :conjugate, :datasets, :interaction_solvents, :solvents, :interaction_additives, :additives, :interaction_related_identifiers, :related_identifiers).published.order(updated_at: :desc).limit(200).ransack(params[:q])
      @selection = @q.result
      @interactions = Kaminari.paginate_array(@selection).page(params[:page]).per(10)
      respond_to do |format|
        format.html
        format.js
      end
    end

    def intsearch
      @interactions = Interaction.order(updated_at: :desc)
    end

    # GET /interactions/1
    # GET /interactions/1.json
    def show
      authorize @interaction, :revision_embargoed?
      @dataset = @interaction.dataset
      if @interaction.published? && @dataset.present?
        unless session[@dataset.id.to_s + "interaction_show_count"]
          @interaction.increment!(:show_count) if @interaction.published?
          @interaction.dataset&.increment!(:view_count) if @interaction.dataset&.state == "findable"
          session[@dataset.id.to_s + "interaction_show_count"] = true
        end
      end
    end

    # GET /interactions/new
    def new
      @interaction = Interaction.new
      @dataset = Dataset.find(params[:dataset_id]) if params[:dataset_id].present?
      #@interaction.embargo = false
    end

    # GET /interactions/1/edit
    def edit
      authorize @interaction, :revision_published?
      @interaction.solvent_additive_checkup
      @dataset = @interaction.dataset
    end

    def reviewer_comments
      authorize @interaction, :revision_submitted?
      respond_to do |format|
        if @interaction.update(interaction_params)
          @interaction.save
          format.html { redirect_to @interaction, notice: 'Thank you for your review. The creator will be informed soon about the current status.' }
        else
          format.html { render @interaction }
        end
      end
    end

    def publish_accepted
      @user = User.find(params[:user_id])
      message = nil
      if params[:interaction_ids].blank?
        message = "Please select some interactions to publish."
      else
      params[:interaction_ids].each{|interaction_id|
        interaction = Interaction.find(interaction_id)
        authorize interaction, :revision_accepted?
        if interaction.update(revision: "published", published: true)
          interaction.save
        else
          message = "Something was not ok with the interactions, please check those in detail, that are not published."
        end
      }
      end
      redirect_to interactions_user_path(@user), notice: message || "All interactions have been published"
    end

    def update_reviewers
      @user = User.find(params[:user_id])
      authorize @user, :admin_tasks
      message = nil
      a=[]
      params[:reviewers].each{|entry|
        interaction = Interaction.find(entry[:interaction_id])
        #reviewer = User.find(entry[:reviewer_id])
        interaction.reviewer_id = entry[:reviewer_id]
        if interaction.changed?
          if interaction.save
            puts "#{interaction.id} was changed"
            a.append interaction.id
            message = "Interactions #{a} were updated"
          else
            message = "Something was not ok with the interactions, please check those in detail, that are not published."
            message = interaction.errors
          end
        end

      }
      redirect_to revisions_user_path(@user), notice: message || "All interactions have been updated"

    end

    def citation_export
      case params[:export]
      when "bibtex"
        send_file(@interaction.bibtex.path,
          filename: "#{@interaction.doi}.bib")
      when "ris"
        send_file(@interaction.ris_export,
          filename: "#{@interaction.doi}.ris")
      when "endnote"
        send_file(@interaction.enw_export,
          filename: "#{@interaction.doi}.enw")

      end
    end

    # POST /interactions
    # POST /interactions.json
    def create
      @interaction = Interaction.new(interaction_params)
      @dataset = Dataset.find(params[:dataset_id]) if params[:dataset_id].present?
      #add exception to raise error if in_technique params are missing
      @interaction.user = current_user
      if @interaction.in_technique_type.present?
        technique_model = @interaction.in_technique_type.singularize.delete(' ').classify.constantize #this is so cool
        puts green technique_model
        puts cyan in_technique_params
        puts red generate_query_from_params(in_technique_params)
        @technique = technique_model.where(generate_query_from_params(in_technique_params)).first_or_create(in_technique_params)
        puts cyan @technique.attributes
        @interaction.in_technique = @technique
      end
      @interaction.assign_primary_dataset(params[:dataset_id]) 
      respond_to do |format|
        if @interaction.save
          @interaction.set_identifier
          @interaction.save
          note = 'Interaction was successfully created.'
          puts "redirect"
          if @interaction.dataset.present?
            format.html { redirect_to dataset_path(@interaction.dataset), notice: note}
          else
            format.html { redirect_to @interaction, notice: note}
          end
        else
          puts "render"
          format.html { render new_interaction_path }
        end
      end
    end

    # PATCH/PUT /interactions/1
    # PATCH/PUT /interactions/1.json
    def update
      authorize @interaction
      technique_model = interaction_params[:in_technique_type].singularize.delete(' ').classify.constantize #this is so cool
      logger.debug "params: #{interaction_params[:in_technique_type]}"
      logger.debug @interaction.in_technique_type
        @technique = technique_model.where(generate_query_from_params(in_technique_params)).first_or_create(in_technique_params)

        logger.debug technique_model
      @interaction.assign_primary_dataset(params[:dataset_id])
      @interaction.in_technique = @technique
      respond_to do |format|
        if @interaction.update(interaction_params)
          unless @interaction.embargo
            @interaction.revision = "submitted"
            @interaction.published = false
            @interaction.save
          end
          format.html { redirect_to @interaction, notice: 'Interaction was successfully updated.' }
        else
          format.html { render :edit }
        end
      end
    end

    def accident
      authorize @interaction, :reviewer_view?
      @interaction.revision = "submitted"
      if @interaction.save
        redirect_to @interaction, notice: 'Interaction was successfully reset'
      else
        redirect_to @interaction, notice: 'Something went wrong please contact contact@suprabank.org'
      end
    end
    # DELETE /interactions/1
    # DELETE /interactions/1.json
    def destroy
      authorize @interaction
      @interaction.archive
      # link = Interaction.find(@interaction.linked_interaction)
      if @interaction.save
      # link.destroy
        respond_to do |format|
          format.html { redirect_to interactions_path, notice: 'Interaction was successfully destroyed.' }
          format.json { head :no_content }
        end
      else
        redirect_to interaction_path(@interaction), notice: 'Something went wrong.'
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.



      def set_interaction
        @interaction = Interaction.includes(:molecule, :host, :in_technique, :buffer, :user, :indicator, :conjugate, :datasets, :interaction_solvents, :solvents, :interaction_additives, :additives, :interaction_related_identifiers, :related_identifiers).find(params[:id])

      end

      def set_meta_data
        if @interaction.present?
          @title = "SupraBank - Interactions - #{@interaction.id}"
          #generic
          @meta_title = @title
          @meta_description = "Interaction  #{@interaction.id} at SupraBank"
          @meta_image = "logo-production.png"
          #open graph facebook
          @meta_og_url = polymorphic_url(@interaction, host:"https://suprabank.org", :protocol => 'https' )
          # twitter card markup
        else
          @title = "SupraBank - Interactions"
          @meta_title = @title
          @meta_description = "Find interactions at SupraBank"
          @meta_image = "logo-production.png"
          @meta_og_url = "https://suprabank.org/interactions"
        end
      end

      def set_molecule
        @molecule = Molecule.find(params[:id])
      end

      def in_technique_params
        params.fetch(:in_technique, {})
        params.fetch(:in_technique, {}).permit(
          :instrument, :lambda_em, :lambda_ex, :lambda_obs, :free_to_bound, :shift_bound, :shift_unbound,
          :delta_shift, :nucleus, :cell_volume, :concentration_molecule, :syringe_volume,
          :initial_injection_volume, :injection_volume, :injection_number, :concentration_host, :concentration_indicator,
          :concentration_conjugate, :magnetic_flux_obs, :nu_obs,
          :molecule_cell, :host_cell, :indicator_cell, :conjugate_cell
        )
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def interaction_params
        params.fetch(:interaction, {})
        params.require(:interaction).permit(
:method,:nucleus, :assay_type, :technique,:solvent_system,:solubility,
:binding_constant, :binding_constant_error, :binding_constant_unit,:binding_range,
:logKa, :logka_error,
:molecule_id, :molecule_name, :lower_molecule_concentration, :upper_molecule_concentration,
:host_id, :host_name, :lower_host_concentration, :upper_host_concentration,
:indicator_id, :indicator_name, :lower_indicator_concentration,:upper_indicator_concentration,
:conjugate_id, :conjugate_name, :lower_conjugate_concentration, :upper_conjugate_concentration,
:temperature, :pH, :solvent,
:second_solvent,
:second_solvent_vol_perc,
:third_solvent,
:third_solvent_vol_perc,
:host_cofactor_wt, :host_indicator_wt,
:host_suspension, :host_wt_low, :host_wt_high, 
:doi,
:dataset_title,
:dataset_id,
:published,
:embargo,
:revision,
:revision_comment,
:variation,
:itc_deltaH, :itc_deltaH_error, :itc_deltaST, :itc_deltaST_error,
:kin_hg, :kin_hg_error, :kin_hg_unit, :kout_hg, :kout_hg_error, :kout_hg_unit,
:icd, :ct_band, :lambda_em, :lambda_ex, :free_to_bound_FL,
:data,
:is_listed,
:revisions_reply,
:deltaG, :deltaG_error,
:buffer_name,
:ionic_strength,
:nmrshift,
:comment,
:stoichometry_host, :stoichometry_molecule, :stoichometry_conjugate, :stoichometry_indicator,
:in_technique,
:in_technique_type,
:in_technique_id,
:solvent_name, :second_solvent, :third_solvent, :fourth_solvent, :vol_perc,
:additive_name,:second_additive, :third_additive, :fourth_additive, :additive_conc,
 solvents_attributes:[:display_name, :id, :_destroy],
 interaction_additives_attributes: [:_destroy, :id, :interaction_id, :concentration, :additive_id, :additive_name, :second_additive_name, :third_additive_name, :fourth_additive_name],
 interaction_solvents_attributes: [:_destroy, :id, :interaction_id, :volume_percent, :solvent_id, :first_solvent_name, :second_solvent_name, :third_solvent_name, :fourth_solvent_name]
            )
      end
end
