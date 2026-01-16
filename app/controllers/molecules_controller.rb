class MoleculesController < ApplicationController
  before_action :set_molecule, only: [:show, :edit, :update, :destroy, :pubchem_update_query, :pubchem_auto_update, :update_framework_molecule]
  before_action :set_interactions, only: [:interactions]
  before_action :set_meta_data
  before_action :authenticate_user!, except: [:tags, :show, :index, :listing, :dbsearch, :interactions, :query, :query_tags, :chemeditor, :edit_comment, :editorsearch, :smilesquery]
  before_action :sole_molecule, only: [:destroy]

include Suprababel
include PDB
include Pubchem
include Colors

  def pubchem_update_query
    array = @molecule.entry_update
    logger.debug array
    unless array.empty?
      results = @molecule.preliminary_update_request(array[0..9])
    else
      results = [["nothing found"]]
    end
    render json: results
  end

  def pubchem_auto_update
    @molecule.auto_update
    #redirect_to molecule_path(@molecule)
    render js: "window.location='#{molecule_path(@molecule).to_s}'"
  end

  def pubchem_update
    logger.debug "action fired"
    logger.debug "params: #{params}"

    if params[:selection_cid].present?
      id = params[:molecule_id].to_i
      cid = params[:selection_cid].to_i
      logger.debug "cid: #{cid}, id: #{id}"
      @molecule = Molecule.find(params[:molecule_id].to_i)
      @molecule.cid = params[:selection_cid].to_i
      @molecule.full_data(@molecule.cid)
      @molecule.clip_png
      @molecule.add_names
      @molecule.add_cas
      @molecule.save
    end
    redirect_to molecule_path(params[:molecule_id])
  end


  def smilesquery
      regexp = /#{params[:term]}/i; # case-insensitive regexp based on your string
      regexresult = Molecule.order(:display_name).where({ iso_smiles: URI.encode(params[:term].upcase) })
      result= regexresult.sort{|x, y| (x =~ regexp) <=> (y =~ regexp) }
      array = result.map{|n| [n.preferred_abbreviation , n.display_name, n.png_url, n.molecular_weight, n.id, n.iso_smiles]}
      render json: array.sort_by{|word| word[1].length }[0..5]
  end

  def query
      regexp = /#{params[:term]}/i; # case-insensitive regexp based on your string
      regexresult = Molecule.select(:preferred_abbreviation, :display_name, :molecular_weight, :png_url, :molecule_type).order(:display_name).where("display_name ILIKE ? OR preferred_abbreviation ILIKE ?", "%#{params[:term]}%", "%#{params[:term]}%")
      result= regexresult.sort{|x, y| (x =~ regexp) <=> (y =~ regexp) }
      array = result.map{|n| [n.preferred_abbreviation , n.display_name, n.png_url.present? ? n.png_url : "/images/thumb/missing.png", n.molecular_weight, n.molecule_type]}
      render json: array.sort_by{|word| word[1].length }[0..5]
  end


  def query_tags
    #tags = ActsAsTaggableOn::Tag.where("name ILIKE ?", "%#{params[:q]}%")
    tags = ActsAsTaggableOn::Tag.includes(:taggings).where(taggings: {context: "tags"}).where("name ILIKE ?", "%#{params[:q]}%")
    #only tags that are tagged to a molecule (in use) are searched
    render json: tags
  end

  def interactions

  end

  def chemeditor

  end

  def tag_cloud
    authorize Molecule, :editor_or_admin?
    @tags = Molecule.tag_counts_on(:tags)
  end


  def edit_comment
    @comment = params[:molefile]
    flash.now[:warning] = "Nothing found in database Molecules #{params[:molefile]}"
    hash_data = { "Jane Doe" => 10, "Jim Doe" => 6 , "Param" => params[:molefile]}
    molfile = "CWRITER308281317412D\nCreated with ChemWriter - http://chemwriter.com\n  2  1  0  0  0  0  0  0  0  0999 V2000\n   67.4074  -47.2503    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n   76.0677  -42.2503    0.0000 N   0  0  0  0  0  0  0  0  0  0  0  0\n  1  2  1  0  0  0\nM  END"
    info_hash = molecule_info_from_molfile(params[:molefile])
    json_data = info_hash.to_json
    render json: json_data
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

  def external_services
    respond_to do |format|
      format.html {}
      format.js
    end
  end

  def pubchem_help
    respond_to do |format|
      format.html {}
      format.js
    end
  end

  def pdb_help
    respond_to do |format|
      format.html {}
      format.js
    end
  end

  def framework_help
    respond_to do |format|
      format.html {}
      format.js
    end
  end

  def pdb_id_request
    if params[:pdb_id].blank?
      flash.now[:warning] = 'You need to put some PDB ID'
      render partial: 'dbresult'
    else
      unless protein_presence?(params[:pdb_id])
        if valid_pdb_id?(params[:pdb_id])
          @molecule = Molecule.new(preliminary_pdb_data(params[:pdb_id]))
        else
          hash = preliminary_pdb_data(params[:pdb_id])
          case hash[:status]
          when 404
            flash.now[:danger] = "We could not find anything, please verify PDB ID."
          when 500
            flash.now[:danger] = "We are sorry the service is currently unavailable."
          end
        end
        render partial: "molecules/pdb/pdb_preliminary_result"
      else
        @molecule=Molecule.find_by_pdb_id(params[:pdb_id])
        @molecule=Molecule.where("lower(pdb_id) = ?", params[:pdb_id].downcase).first
        flash.now[:success] = "The molecule exists already in the SupraBank"
        render partial: 'molecules/found_result'
      end
    end
  end

  def pubchem_request
    if params[:molecule].blank?
      flash.now[:warning] = 'You need to put some search string'
      render partial: 'dbresult'
    else
      @molecule = Molecule.new
      @molecule.preliminary_data params[:molecule]
      if @molecule.molecule_presence(@molecule.cid)
        @molecule=Molecule.find_by_cid(@molecule.cid)
        flash.now[:success] = "The molecule exists already in the SupraBank."
        render partial: 'molecules/found_result'
      elsif @molecule.cid.present?
        flash.now[:success] = "The molecule is present on PubChem, but not yet at SupraBank, you can retrieve it!"
        render partial: "molecules/preliminary_result"
      else
        flash.now[:warning] = 'Unfortunately, we could not find anything on PubChem. Please first check directly on PubChem for the name and the CID and use here afterwards the "Use CID Instead" option on the right. If the substance is not listed on PubChem, you can create a custom molecule on SupraBank:'
        render partial: "molecules/nothing_found"
      end
    end
  end



  def cid_request
    if params[:request_cid].blank?
      flash.now[:warning] = 'You need to put the PubChem Compound ID (CID)'
      render partial: 'dbresult'
    else
      unless molecule_presence(params[:request_cid])
        @molecule = Molecule.new
        @molecule.preliminary_cid_data params[:request_cid]
        render partial: "molecules/preliminary_result"
      else
        @molecule=Molecule.find_by_cid params[:request_cid]
        flash.now[:success] = "The molecule exists already in the SupraBank"
        render partial: 'molecules/found_result'
      end
    end
  end

  def pdb_full_record
    unless protein_presence?(params[:pdb_id])
      @molecule = Molecule.new(pdb_summary_data(params[:pdb_id]))
      @molecule.display_name = @molecule.pdb_descriptor
      @molecule.preferred_abbreviation = @molecule.display_name
      @molecule.tag_list.add("protein")
      @molecule.clip_protein_png
      @message = "Your molecule was successfully added to the SupraBank"
    else
      @molecule=Molecule.find_by_pdb_id(params[:pdb_id])
      flash.now[:success] = "The molecule exists already in the SupraBank"
    end

    respond_to do |format|
      format.js
    end
  end

  def pubchem_full_record
    @molecule = Molecule.new(cid: params[:cid])
    unless @molecule.molecule_presence(@molecule.cid)
      @molecule.user = current_user
      @molecule.full_data params[:cid]
      @molecule.clip_png
      @molecule.add_names
      @molecule.add_cas
      @molecule.save
      @message = "Your molecule was successfully added to the SupraBank"
    else
      @molecule=Molecule.find_by_cid(params[:cid])
      @message = "The molecule exists already in the SupraBank"
    end

    respond_to do |format|
      format.js
    end
  end


  def listing
    
    @molecules = policy_scope(Molecule).select(:id, :cid, :display_name, :preferred_abbreviation, :molecular_weight, :inchistring, :inchikey, :cano_smiles, :iso_smiles, :interactions_count, :updated_at, :created_at, :png_url)

  end

  def destroy
    authorize @molecule
    @molecule.destroy
    respond_to do |format|
      format.html { redirect_to molecules_path, notice: 'Molecule was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  def search
    if params[:molecule].blank?
      flash.now[:warning] = 'You need to put some search string'
    else
      @molecule = Molecule.new_from_name(params[:molecule])

      if @molecule.present?
        if @molecule == "exist"
          @molecule = Molecule.dbsearch(params[:molecule]).first
          flash.now[:success] = 'Molecule is already present in the SupraBank'
        else
          @molecule.user = current_user
          @molecule.save
          flash.now[:success] = 'Molecule was added successfully to the SupraBank'
        end
      else
        flash.now[:warning] = 'Nothing found by Name at PubChem. You may try with the CAS number?'
      end
    end
    render partial: 'molecules/result'
  end



  def dbsearch
      if params[:search_param].blank? && params[:tags_param].blank?
        flash.now[:warning] = 'You need to put some content'
        render partial: 'dbresult'
      else
        @molecules = Molecule.dbsearch(params[:search_param],params[:tags_param])
        if @molecules.present?
          render partial: 'dbresult'
        else
          flash.now[:warning] = 'Nothing found in the database Molecules' if @molecules.blank?
          render partial: 'dbresult'
        end
      end
  end

  def framework_dbsearch
      if params[:framework_search].blank? 
        flash.now[:warning] = 'You need to put some content'
      else
        @molecules = Molecule.dbsearch(params[:framework_search], nil)
        unless @molecules.present?
          flash.now[:warning] = 'Nothing found in the database Molecules' if @molecules.blank?
        end
      end
      render partial: 'framework_result'
  end

  def editorsearch

    array = params[:search_param].split("\n")
    empty = "  0  0  0  0  0  0  0  0  0  0999 V2000\r"
    if array[-2] == empty
        flash.now[:warning] = 'You need to put some content'
      else
        info_hash = molecule_info_from_molfile(params[:search_param])
        if params[:button]=='exact'
          inchi=info_hash[:inchi]
          #flash.now[:warning] = "You need to put some #{finger}"
          @molecules = Molecule.exacteditorsearch(inchi)
        elsif params[:button]=='smiles'
          smile=info_hash[:cano_smiles]
          @molecules = Molecule.smileseditorsearch(smile)
          #flash.now[:warning] = "You need to put some #{finger}"
        end

        unless @molecules.present?
          flash.now[:warning] = 'Nothing found in the database Molecules'
        end
    end
    render partial: 'dbresult'
  end

    def pogresearch
        if params[:search_param].blank?
          flash.now[:warning] = 'You need to put some content'
          render partial: 'pgresult'
        else
          @molecules = Molecule.pogsearch(params[:search_param])
          if @molecules.present?
            render partial: 'pgresult'
          else
            flash.now[:warning] = 'Nothing found in the database Molecules' if @molecules.blank?
            render partial: 'pgresult'
          end
        end
    end

  # GET /molecules
  # GET /molecules.json

  def index
    @molecules = Molecule.all
  end

  # GET /molecules/1
  # GET /molecules/1.json
  def show
  end

  # GET /molecules/new
  def new
    @molecule = Molecule.new
  end

  def new_molecule
    @molecule = Molecule.new(molecule_type: 'compound')
  end

  def new_framework
    @molecule = Molecule.new(molecule_type:'framework')
  end
  

  # GET /molecules/1/edit
  def edit
    authorize @molecule
  end

  # POST /molecules
  # POST /molecules.json
  def create

    @molecule = Molecule.new(molecule_params)
    @molecule.user = current_user
  #  @molecule.check_cid
  #  @molecule.generate_molecule_data
    respond_to do |format|
      if @molecule.save
        format.html { redirect_to edit_molecule_path(@molecule), notice: 'SupraBank created successfully a molecule. Please thoroughly check everything and update accordingly.' }
        format.json { render :show, status: :created, location: @molecule }
      else
        format.html { render :new }
        format.json { render json: @molecule.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_framework_molecule
    @molecule = Molecule.new(molecule_params)
    @molecule.molecule_type = "framework";
    @molecule.user = current_user;
    puts green "framework molecule params #{framework_molecule_params[:si_al_ratio]}"
    @molecule.assign_framework_molecule(params[:framework_id], framework_molecule_params[:si_al_ratio], params[:additive_id])
    @molecule.tag_list.add("framework")
    respond_to do |format|
      if @molecule.save
        format.html { redirect_to molecule_path(@molecule), notice: 'SupraBank created successfully a new framework.' }
        format.json { render :show, status: :created, location: @molecule }
      else
        format.html { render :new }
        format.json { render json: @molecule.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_framework_molecule
    #authorize @molecule
    puts green "framework molecule params #{framework_molecule_params[:si_al_ratio]}"
    @molecule.assign_framework_molecule(params[:framework_id], framework_molecule_params[:si_al_ratio], params[:additive_id])
    
    respond_to do |format|
      if @molecule.update(molecule_params)
        format.html { redirect_to molecule_path(@molecule), notice: 'Molecule was successfully updated.' }
        format.json { render :show, status: :created, location: @molecule }
      else
        format.html { render :new }
        format.json { render json: @molecule.errors, status: :unprocessable_entity }
      end
    end
  end
  
  

  # PATCH/PUT /molecules/1
  # PATCH/PUT /molecules/1.json
  def update
    authorize @molecule
    respond_to do |format|
      if @molecule.update(molecule_params)
        format.html { redirect_to @molecule, notice: 'Molecule was successfully updated.' }
        format.json { render :show, status: :ok, location: @molecule }
      else
        format.html { render :edit }
        format.json { render json: @molecule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /molecules/1
  # DELETE /molecules/1.json
  # def destroy
  #   @molecule.destroy
  #   respond_to do |format|
  #     format.html { redirect_to listing_molecules_path, notice: 'Molecule was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.


    def set_molecule
      @molecule = Molecule.find(params[:id])
    end

    def set_interactions
      @molecule = Molecule.find(params[:id])
      @molecule_interactions = Interaction.includes(:molecule, :host, :in_technique, :buffer, :user, :indicator, :conjugate, :datasets, :interaction_solvents, :solvents, :interaction_additives, :additives, :interaction_related_identifiers, :related_identifiers).active.where(molecule:@molecule)
      @host_interactions = Interaction.includes(:molecule, :host, :in_technique, :buffer, :user, :indicator, :conjugate, :datasets, :interaction_solvents, :solvents, :interaction_additives, :additives, :interaction_related_identifiers, :related_identifiers).active.where(host:@molecule)
      @interactions = (@molecule_interactions + @host_interactions).uniq
      @indicator_interactions = Interaction.includes(:molecule, :host, :in_technique, :buffer, :user, :indicator, :conjugate, :datasets, :interaction_solvents, :solvents, :interaction_additives, :additives, :interaction_related_identifiers, :related_identifiers).active.where(indicator:@molecule)
      @conjugate_interactions = Interaction.includes(:molecule, :host, :in_technique, :buffer, :user, :indicator, :conjugate, :datasets, :interaction_solvents, :solvents, :interaction_additives, :additives, :interaction_related_identifiers, :related_identifiers).active.where(conjugate:@molecule)
      @overall_interactions_size = @interactions.size + @indicator_interactions.size + @conjugate_interactions.size
    end
    

    def set_meta_data
      if @molecule.present?
        @title = "SupraBank - Molecules - #{@molecule.display_name}"
        #generic
        @meta_title = @title
        @meta_description = "Compound  #{@molecule.display_name.present? ? @molecule.display_name : "no name present"} at SupraBank"
        @meta_image = @molecule.png.present? ? @molecule.png.url : "logo-production.png"
        #open graph facebook
        @meta_og_url = polymorphic_url(@molecule, host:"https://suprabank.org", :protocol => 'https' )
        # twitter card markup
      else
        @title = "SupraBank - Molecules"
        @meta_title = @title
        @meta_description = "Find molecules at SupraBank"
        @meta_image = "logo-production.png"
        @meta_og_url = "https://suprabank.org/molecules"
      end
    end



    def sole_molecule
      overall_interactions_size = Interaction.active.where(molecule:@molecule).size + Interaction.active.where(indicator:@molecule).active.size + Interaction.active.where(host:@molecule).size  + Interaction.active.where(conjugate:@molecule).size
     unless overall_interactions_size == 0

       flash[:danger] = "Only a molecule without interactions might be destroyed"

       redirect_to root_path

     end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def molecule_params
      params.fetch(:molecule, {})
      params.require(:molecule).permit(:molecule_type, :display_name, :names, :cid, :svg, :cdx, :preferred_abbreviation, :cas, :molecular_weight, :sum_formular, :inchikey, :inchistring, :cano_smiles, :iso_smiles,  :h_bond_donor_count, :h_bond_acceptor_count, :bond_stereo_count, :atom_stereo_count, :volume_3d, :conformer_count_3d, :complexity, :iupac_name, :charge, :fingerprint_2d, :png, :png_file_name, :mdl_string, :tag_list, :framework_id, :framework_code, :framework_molecule)
    end

    def framework_molecule_params
      params.fetch(:framework_molecule, {})
      params.require(:framework_molecule).permit(:si_al_ratio)
    end
end
