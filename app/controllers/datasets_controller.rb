class DatasetsController < ApplicationController
  include Colors
  before_action :set_dataset, only: [:edit, :edit_interactions, :update, :destroy, :interaction_addition, :update_state, :dataset_csv_export, :citation_export, :self_revision_temp]
  before_action :authenticate_user!, except: [:index, :show, :preview, :preview_modal]
  before_action :set_meta_data_collection, except: [:show, :preview_modal, :edit]
  before_action :set_meta_data_member, only: [:show, :edit]
  before_action :set_meta_data_preview, only: [:preview]

  def query_subjects
    #subjects = ActsAsTaggableOn::Tag.where("name ILIKE ?", "%#{params[:q]}%")
    subjects = ActsAsTaggableOn::Tag.includes(:taggings).where(taggings: {context: "subjects"}).where("name ILIKE ?", "%#{params[:q]}%")
    #only subjects that are tagged to a molecule (in use) are searched
    render json: subjects
  end


  def citation_export
    case params[:export]
    when "bibtex"
      send_file(@dataset.bibtex.path,
        filename: "#{@dataset.identifier}.bib")
    when "ris"
      send_file(@dataset.ris_export,
        filename: "#{@dataset.identifier}.ris")
    when "endnote"
      send_file(@dataset.enw_export,
        filename: "#{@dataset.identifier}.enw")
    end
    unless session[@dataset.id.to_s + "dataset_citation_export_count"]
      if @dataset.state == 'findable'
        @dataset.increment!(:citation_export_count)
      end
      session[@dataset.id.to_s + "dataset_citation_export_count"] = true
    end
  end

  def update_state
    authorize @dataset, :update?
      logger.debug params
      case params[:commit]
      when "Register Dataset"
        @dataset.state = "registered"
        @dataset.mere_dataset
        note = 'Dataset was successfully registered.'
      when "Revert to Registered"
        @dataset.state = "registered"
        note = 'Dataset was successfully reverted to register.'
      when "Publish Dataset"
        @dataset.state = "findable"
        note = 'Dataset was successfully published.'
      end
      respond_to do |format|
        logger.debug "The dataset's state is: #{@dataset.state}"
        @dataset.cache_toc_graphic
        if @dataset.save
          format.html { redirect_to @dataset, notice:  note}
          format.json { render :show, status: :created, location: @dataset }
        else
          format.html { redirect_to @dataset, notice: 'Error.' }
          format.json { render json: @dataset.errors, status: :unprocessable_entity }
        end
      end

  end

  def query_user_datasets_editable
      regexp = /#{params[:term]}/i; # case-insensitive regexp based on your string
      regexresult = current_user.datasets.editable.order(:title).where("title ILIKE ?", "%#{params[:term]}%")
      result= regexresult.sort{|x, y| (x =~ regexp) <=> (y =~ regexp) }
      array = result.map{|n| [n.title , n.identifier, n.state, n.id]}
      render json: array.sort_by{|word| word[1].length }[0..5]
  end

  def query
      regexp = /#{params[:term]}/i; # case-insensitive regexp based on your string
      regexresult = current_user.datasets.order(:title).where("title ILIKE ?", "%#{params[:term]}%")
      result= regexresult.sort{|x, y| (x =~ regexp) <=> (y =~ regexp) }
      array = result.map{|n| [n.title , n.identifier, n.state]}
      render json: array.sort_by{|word| word[1].length }[0..5]
  end

  def self_revision_temp
    authorize @dataset, :self_revision?
    interactions = @dataset.interactions
    interactions.update_all(
      revision: "accepted", 
      revision_comment: "self accepted on #{Time.now.to_s}",
      embargo: false
    )
    flash[:success] = "All interactions have been accepted. When you click publish, they will be published and findable."
    redirect_to dataset_path(@dataset)
  end
  


  def dataset_csv_export
    authorize @dataset, :csv_exportable?
    @dataset.csv_export
    send_file(
      @dataset.csv_export,
      filename: "#{@dataset.identifier}.csv")
    unless session[@dataset.id.to_s + "dataset_download_count"]
      if @dataset.state == 'findable'
        @dataset.increment!(:download_count)
      end
      session[@dataset.id.to_s + "dataset_download_count"] = true
    end
  end


  def query_cooperators
      unless params[:familyName].present?
        familyName = ""
      else
        familyName = params[:familyName]
      end

      regexp = /#{params[:familyName]}/i; # case-insensitive regexp based on your string
      creators = Creator.where('"familyName" ILIKE ?', "%#{familyName}%").order(:familyName) #.or(Creator.where('"givenName" ILIKE ?', "%#{givenName}%"))
      contributors = Contributor.where('"familyName" ILIKE ?', "%#{familyName}%").order(:familyName) #.or(Contributor.where('"givenName" ILIKE ?', "%#{givenName}%"))
      users = User.where('"familyName" ILIKE ?', "%#{familyName}%").order(:familyName) #.or(User.where('"givenName" ILIKE ?', "%#{givenName}%"))
      regexresult = creators + contributors + users
      regexresult = regexresult.uniq{|e| [e[:nameIdentifier], e[:givenName], e[:familyName]]}
      result= regexresult.sort{|x, y| (x =~ regexp) <=> (y =~ regexp) }
      array = result.map{|n| [n.givenName , n.familyName, n.nameIdentifier, n.affiliation, n.affiliationIdentifier, n.id, n.model_name.name]}
      render json: array.uniq.sort_by{|word| word[1].length }
  end






  def preview_modal
    @interaction = Interaction.find(params[:interaction_id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def citation_query
    #:dataset_related_identifiers_attributes[0][relatedIdentifier]
    result = Dataset.citation_request(params[:term])
    array = [result[:title], result[:abstract], result[:author].to_json]
    render json: result.to_json
  end


  # GET /datasets
  # GET /datasets.json
  def index
    @q = Dataset.findable.select(:id, :identifier, :title, :rightsURI, :rightsIdentifier, :state, :created_at, :size_count, :citation).order(size_count: :desc).ransack(query_params)
    #@q=Dataset.findable.ransack(params[:q])
    @selection = @q.result(distinct: true).includes(:creators, :interactions)
    @datasets = Kaminari.paginate_array(@selection).page(params[:page]).per(10)
    respond_to do |format|
      format.html
      format.js
    end
  end


  # GET /datasets/1
  # GET /datasets/1.json
  def show
    @dataset = Dataset.includes(:dataset_related_identifiers, :interactions, :creators).find(params[:id])
    authorize @dataset, :displayable?
    @dataset.last_creator_standing
    @dataset.unitize_dataset_creators
    @dataset.json2citation
    @dataset.curation_status
    @qincluded = @dataset.interactions.active.includes(:solvents, :molecule).ransack(params[:q])
    @included = @qincluded.result
    limit = params[:limit] || 5
    @interactions_included = Kaminari.paginate_array(@included).page(params[:page]).per(limit)
    unless session[@dataset.id.to_s + "dataset_show_count"]
      if @dataset.state == 'findable'
        @dataset.increment!(:show_count)
        @dataset.increment!(:view_count)
      end
      session[@dataset.id.to_s + "dataset_show_count"] = true
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def preview
    #@dcidentifier = "https://suprabank.org"
    @dataset = Dataset.includes(:dataset_related_identifiers, :interactions, :creators).find_by_preview_token(params[:id])
    @dataset.unitize_dataset_creators
    @dataset.json2citation
    @dataset.curation_status
    @qincluded = @dataset.interactions.active.includes(:solvents, :molecule).ransack(params[:q])
    @included = @qincluded.result
    limit = params[:limit] || 5
    @interactions_included = Kaminari.paginate_array(@included).page(params[:page]).per(limit)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def interaction_addition

  end
  # GET /datasets/new
  def new
    @dataset = Dataset.new

  end

  # GET /datasets/1/edit
  def edit
    #@dataset.dataset_creators.build
  end

  def add_interactions
    @dataset = Dataset.find(params[:dataset_id])
    authorize @dataset, :update?
    params[:interaction_ids].each{|interaction_id|
      dataset_interaction = DatasetInteraction.create(:dataset_id => params[:dataset_id], :interaction_id => interaction_id)
      dataset_interaction.add_interaction_identifier_association
    }  #this is slower (factor 3-4)
    #params[:interaction_ids].each{|interaction_id| @dataset.dataset_interactions.build(:interaction_id => interaction_id)}
    #Interaction.where(id: params[:interaction_ids]).find_each{|i| i.update(:dataset_id => params[:dataset_id])}
    flash.now[:errors]
    redirect_to dataset_path(params[:dataset_id])
  end

  def remove_interactions
    @dataset = Dataset.find(params[:dataset_id])
    authorize @dataset, :update?
    #params[:interaction_ids].each{|interaction_id| DatasetInteraction.where('dataset_id = ? AND interaction_id = ?',params[:dataset_id],interaction_id).first.destroy } #this is slower (factor 3-4)
    if params[:interaction_ids].present?
      params[:interaction_ids].each{|interaction_id| @dataset.dataset_interactions.find_by_interaction_id(interaction_id).destroy}
      flash[:success] = "The selected interactions have been successfully removed from the dataset."
      redirect_to dataset_path(@dataset)
    else
      flash[:warning] = "Please select interactions to be removed."
      redirect_to dataset_path(@dataset)
    end
  end

  def update_dataset_interactions_dois
    @dataset = Dataset.find(params[:dataset_id])
    @dataset.update_interaction_dois
    redirect_to dataset_path(@dataset), notice: "The included interactions DOIs have been updated."
  end

  def initialize_dataset_interaction_revision
    @dataset = Dataset.find(params[:dataset_id])
    @dataset.initialize_revision
    redirect_to dataset_path(@dataset), notice: "The included interactions have been updated."
  end

  def advsearch
    if params[:button] == "list_all"
      @interactions = Dataset.find(params[:dataset_id]).addition_scope(current_user) #apply scope here
      flash.now[:warning] = "No Interaction was found. Or they are already included in your dataset" if @interactions.blank?
    elsif params[:button] == "search"
      if params[:molecule_param].blank? & params[:mol_tags_param].blank? & params[:host_param].blank? & params[:host_tags_param].blank? & params[:binding_param].blank? & params[:binding_to_param].blank? & params[:technique_param].blank? & params[:assay_type_param].blank? & params[:supplement_param].blank? & params[:doi_param].blank? & params[:author_param].blank? & params[:year_param].blank? & params[:solvent_param].blank? & params[:buffer_param].blank? & params[:pH_param].blank? & params[:pH_to_param].blank? & params[:temperature_param].blank? & params[:temperature_to_param].blank?
        flash.now[:warning] = 'You need to put some content'
      else
        interactions = Dataset.find(params[:dataset_id]).addition_scope(current_user)
        @interactions = interactions.advsearch(params[:molecule_param],params[:mol_tags_param],params[:host_param],params[:host_tags_param],params[:binding_param],params[:binding_to_param],params[:technique_param],params[:assay_type_param],params[:supplement_param], params[:doi_param], params[:author_param], params[:year_param], params[:solvent_param], params[:buffer_param], params[:pH_param], params[:pH_to_param], params[:temperature_param], params[:temperature_to_param], params[:molecule_exclusive_param], params[:host_exclusive_param], params[:host_or_param])
        flash.now[:warning] = "No Interaction was found. Or they are already included in your dataset" if @interactions.blank?
      end
    end
    render partial: 'advresult', locals: {dataset_id: params[:dataset_id]}
  end



  # GET /datasets/1/edit


  # POST /datasets
  # POST /datasets.json
  def create
    @dataset = Dataset.new(dataset_params)
    @dataset.users << current_user

    if params[:role] == "post"
      jsonparser = params[:authors] && params[:authors].length >= 2 ? JSON.parse(URI.decode(params[:authors])) : nil
      if jsonparser.present?
        authors=jsonparser.each{|obj| obj.deep_symbolize_keys!}
        @dataset.initialize_creator_references(authors)#works
        @dataset.scholarArticleState = 3
      end
      #logger.debug "Dataset RI 1.:#{@dataset.dataset_related_identifiers.first.attributes}"
      #@dataset.reference_doi(@dataset.primary_reference) #causes some probs
    elsif params[:role] == "pre"
      @dataset.initialize_creator
      @dataset.scholarArticleState = 1
    end

  respond_to do |format|
    logger.debug blue "inside respond to from create"
    if @dataset.save
      #@dataset.assign_reference_interactions
      logger.debug green "dataset was saved"
      @dataset.generate_doi #works
      @dataset.meta_updater
      @dataset.json2citation
      @dataset.save
    format.html { redirect_to @dataset, notice: 'Dataset was successfully created.' }
    #format.json { render :show, status: :created, location: @dataset }
    else
      flash[:error] = @dataset.errors.full_messages
      format.html {
        redirect_to new_dataset_path }
      #format.json { render json: @dataset.errors, status: :unprocessable_entity }
    end
  end
  end

  # PATCH/PUT /datasets/1
  # PATCH/PUT /datasets/1.json
  def update
    logger.debug "Controller update params: #{params}"
    respond_to do |format|
      if @dataset.update(dataset_params)
        #logger.debug "Parameter: #{dataset_params[:dataset_creators_attributes]}
        #@dataset.dataset_creators.update_all
        # @dataset.creators_update(dataset_params[:dataset_creators_attributes])
        @dataset.creators_update(dataset_params[:dataset_creators_attributes])
        #logger.debug "Parameter: #{dataset_params[:dataset_contributors_attributes]}"
        @dataset.contributors_update(dataset_params[:dataset_contributors_attributes])
        jsonparser = params[:authors] && params[:authors].length >= 2 ? JSON.parse(URI.decode(params[:authors])) : nil
        if jsonparser.present?
          authors=jsonparser.each{|obj| obj.deep_symbolize_keys!}
          @dataset.initialize_creator_references(authors)#works
        end
        #logger.debug @dataset
        @dataset.meta_updater
        @dataset.json2citation
        @dataset.save
        format.html { redirect_to @dataset, notice: 'Dataset was successfully updated.' }
        format.json { render :show, status: :ok, location: @dataset }
      else
        flash[:error] = @dataset.errors.full_messages
        format.html { redirect_to edit_dataset_path(@dataset) }
        format.json { render json: @dataset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /datasets/1
  # DELETE /datasets/1.json
  def destroy
    @dataset.destroy
    respond_to do |format|
      format.html { redirect_to datasets_url, notice: 'Dataset was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dataset
      @dataset = Dataset.includes(:dataset_related_identifiers, :interactions, :creators).find(params[:id])
    end

    def set_meta_data_collection
      @dcidentifier = "https://suprabank.org"
        @title = "SupraBank - Datasets"
        @meta_title = @title
        @meta_description = "Find datasets at SupraBank"
        @meta_image = "logo-production.png"
        @meta_og_url = "https://suprabank.org/datasets"
    end

    def set_meta_data_member
      @dcidentifier = "https://suprabank.org"
      set_dataset
      if @dataset.present?
        @title = "SupraBank - #{@dataset.title}"
        #generic
        @meta_title = @title
        @meta_description = "#{@dataset.description}"
        @meta_image = @dataset.img_url
        #open graph facebook
        @meta_og_url = polymorphic_url(@dataset, host:"https://suprabank.org", :protocol => 'https' )
        # twitter card markup
      else
        @title = "SupraBank - Datasets"
        @meta_title = @title
        @meta_description = "Find datasets at SupraBank"
        @meta_image = "logo-production.png"
        @meta_og_url = "https://suprabank.org/datasets"
      end
    end

    def set_meta_data_preview
      @dcidentifier = "https://suprabank.org"
      @dataset = Dataset.includes(:dataset_related_identifiers, :interactions, :creators).find_by_preview_token(params[:id])
      if @dataset.present?
        @title = "SupraBank - #{@dataset.title}"
        #generic
        @meta_title = @title
        @meta_description = "#{@dataset.description}"
        @meta_image = @dataset.img_url
        #open graph facebook
        @meta_og_url = polymorphic_url(@dataset, host:"https://suprabank.org", :protocol => 'https' )
        # twitter card markup
      else
        @title = "SupraBank - Datasets"
        @meta_title = @title
        @meta_description = "Find datasets at SupraBank"
        @meta_image = "logo-production.png"
        @meta_og_url = "https://suprabank.org/datasets"
      end
    end
   



    # Never trust parameters from the scary internet, only allow the white list through.
    def dataset_params
      params.fetch(:dataset, {})
      params.require(:dataset).permit(
      :scholarArticleState,
      :primary_reference,
      :subject_list,
      :rights,
      :title,
      :identifier,
      :publicationYear,
      :subject,
      :description,
      dataset_related_identifiers_attributes:[:id, :dataset_id, :related_identifier_id, :relatedIdentifier, :relationType, :relatedIdentifierType],
      related_identifiers_attributes:[:id, :relatedIdentifier, :relatedIdentifierType],
      dataset_users_attributes:[:id, :dataset_id, :user_id],
      users_attributes:[:id],
      creators_attributes:[:id, :creatorName],
      dataset_creators_attributes:[:_destroy, :id, :dataset_id, :creator_id, :creator_givenName, :creator_familyName, :creator_nameIdentifier, :creator_affiliationIdentifier, :creator_affiliation],
      contributors_attributes:[:id, :contributorName],
      dataset_contributors_attributes:[:_destroy, :id, :dataset_id, :contributorType, :contributor_id, :contributor_givenName, :contributor_familyName, :contributor_nameIdentifier, :contributor_affiliationIdentifier, :contributor_affiliation]
      )
    end
end
