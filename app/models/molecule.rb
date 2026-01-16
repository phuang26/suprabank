# frozen_string_literal: true

class Molecule < ActiveRecord::Base
  # validates :cid, uniqueness: true
  acts_as_taggable_on :tags
  validates :display_name, presence: true, uniqueness: true
  validates :iso_smiles, presence: true, if: -> {molecule_type == 'compound'}
  has_many :interactions
  has_many :hosts, through: :interactions
  has_many :indicators, through: :interactions
  has_many :conjugates, through: :interactions
  has_many :framework_molecules
  has_many :frameworks, through: :framework_molecules
  belongs_to :user
  has_attached_file :svg, styles: { medium: '300x300>', thumb: '100x100>' }, default_url: '/images/:style/missing.png'
  validates_attachment_content_type :svg, content_type: %r{\Aimage/.*\z}
  has_attached_file :png, styles: { medium: '300x300>', thumb: '100x100>' }, default_url: '/images/:style/missing.png'
  validates_attachment_content_type :png, content_type: ['image/jpeg', 'image/gif', 'image/png', 'image/svg+xml', 'text/plain']
  has_attached_file :cdx, validate_media_type: false
  validates_attachment :cdx, {content_type: { content_type: ["chemical/x-cdx', 'chemical/x-chem3d", Paperclip::ContentTypeDetector::SENSIBLE_DEFAULT] }}
  #validates_attachment_content_type :cdx, content_type: ['chemical/x-cdx','image/x-coreldraw', 'chemical/x-chem3d']
  after_create :check_cid, :generate_molecule_data
  before_create :add_xlogP3, :add_ertl_tpsa
  after_save :cache_interactions, :cache_png_url, :update_framework_props
  enum molecule_type: {compound: 0, protein: 1, polymer: 2, surface: 3, framework: 4}
  include PgSearch
  include Suprababel
  include Pubchem
  include PDB

  pg_search_scope :search_by_title,
                  against: %i[display_name iupac_name],
                  using: {
                    tsearch: { dictionary: 'english',
                               any_word: true,
                               prefix: true }
                  }

  pg_search_scope :search_by_names,
                  against: :names,
                  using: {
                    tsearch: { dictionary: 'english',
                               any_word: true,
                               prefix: true }
                  }


                  
  def cache_interactions
    overall_interactions_size = (Interaction.active.published.where(molecule:self) +  Interaction.active.published.where(host:self)).uniq.size + Interaction.active.published.where(indicator:self).size + Interaction.active.published.where(conjugate:self).size || 0
    self.update_column(:interactions_count, overall_interactions_size)
  end

  def cache_png_url
    self.update_column(:png_url, self.png.url)
  end
  

  def framework
    self.frameworks&.first
  end
  
  def framework_molecule
    self.framework_molecules&.first
  end
  

  def assign_framework_molecule(framework_id, si_al_ratio, additive_id)
    if framework_molecules.exists?
      self.framework_molecules.first.update(si_al_ratio: si_al_ratio, framework_id: framework_id)
    else
      self.framework_molecules.build(si_al_ratio: si_al_ratio, framework_id: framework_id)
    end
    if additive_id.present? 
      if framework_molecules.first.framework_molecule_additives.exists?
        self.framework_molecules.first.framework_molecule_additives.first.update(additive_id: additive_id)
      else
        self.framework_molecules.first.framework_molecule_additives.build(additive_id: additive_id)
      end
    end
    
  end

  def update_framework_props
    if molecule_type == "framework"
      self.update_columns(png_url:framework.png_url)
    end
  end
  
  

  def framework_code
    self.frameworks.try(:code)
  end


  def self.pogsearch(param)
    param.strip!
    param.downcase!
    to_send_back = (search_by_title(param) + search_by_names(param)).uniq
    return nil unless to_send_back

    to_send_back
  end

  def self.find_by_id(molecule_id)
    where(id: molecule_id).first
  end



  def pubchem_update_request
    array = []
  end




  def generate_molecule_data
    if cid < 0 && molecule_type == 'compound'
      info_hash = molecule_info_from_smiles(iso_smiles)

      svg = info_hash[:svg]
      smiles = iso_smiles
      name = "app/assets/images/tmp/#{Time.new.to_i}_#{rand}"
      FileUtils.rm_rf(Dir['app/assets/images/tmp/*'])
      FileUtils.mkdir_p name
      #png_file_path = "#{name}/compound.png"
      #mdl_file_path = "#{name}/compound.mdl"
      svg_file_path = "#{name}/compound.svg"
      gif_file_path = "#{name}/compound.svg"
      File.write(svg_file_path, svg)

      smiles_url = URI.encode("http://cactus.nci.nih.gov/chemical/structure/#{smiles}")
      inchi_url = "http://cactus.nci.nih.gov/chemical/structure/#{info_hash[:inchi]}"
      inchikey_url = "http://cactus.nci.nih.gov/chemical/structure/#{info_hash[:inchikey]}"

      base_url = if valid_url?(smiles_url)
                   smiles_url
                 elsif valid_url?(inchi_url)
                   inchi_url
                 else
                   inchikey_url
                 end

      if svg
        image_file = File.open(svg_file_path)
      else
        image_response = HTTP.get(base_url + '/image')
        if image_response.status.code == 200
          IO.copy_stream(open(base_url + '/image'), gif_file_path)
          image_file = File.open(gif_file_path)
        else
          image_file = File.open(svg_file_path)
        end
      end

      self.h_bond_donor_count = HTTP.get(base_url + '/h_bond_donor_count').to_s
      self.h_bond_acceptor_count = HTTP.get(base_url + '/h_bond_acceptor_count').to_s

      self.mdl_string = info_hash[:molfile]
      self.charge = info_hash[:charge]
      self.molecular_weight = info_hash[:mol_wt]
      self.inchikey = info_hash[:inchikey]
      self.inchistring = info_hash[:inchi]
      self.sum_formular = info_hash[:formula]
      self.cano_smiles = info_hash[:cano_smiles]
      #self.png = image_file
      self.fingerprint_2d = info_hash[:fp]

      save
    end
  end


  def check_cid
    unless self.cid.present?
      self.cid = if !Molecule.where('cid < 0').empty?
                   Molecule.where('cid < 0').last.cid - 1
                 else
                   -1
                 end
      save
    end
  end

  def self.dbsearch(name_param, tags_param)

   unless name_param.nil?||name_param.blank?
    name_param.strip!
    name_param.downcase!

    to_send_back = (display_name_matches(name_param, tags_param) + preferred_abbreviation_matches(name_param, tags_param)).uniq

   else
     unless tags_param.nil?||tags_param.blank?
        to_send_back = Molecule.tagged_with("#{tags_param}")
     end
   end

   return nil unless to_send_back
   to_send_back

  end

  def self.exacteditorsearch(inchi)
    to_send_back = Molecule.where("inchistring ilike ?", "%#{inchi}%")
    return nil unless to_send_back
    to_send_back
  end

  def self.smileseditorsearch(smiles)
    to_send_back = Molecule.where("cano_smiles ilike ?", "%#{smiles}%")
    return nil unless to_send_back
    to_send_back
  end

  def self.id_matches(param)
    matches('id', param)
  end

  def self.display_name_matches(name_param, tags_param)
    unless tags_param.nil?||tags_param.blank?
      matches('display_name', name_param).tagged_with("#{tags_param}")
    else
      matches('display_name', name_param)
    end
  end

  def self.preferred_abbreviation_matches(name_param, tags_param)
    unless tags_param.nil?||tags_param.blank?
      matches('preferred_abbreviation', name_param).tagged_with("#{tags_param}")
    else
      matches('preferred_abbreviation', name_param)
    end
  end

  def self.iupac_name_matches(param)
    matches('iupac_name', param)
  end

  def self.iupac_cid_matches(param)
    matches('cid', param)
  end

  def self.matches(field_name, param)
    Molecule.where("#{field_name} ilike ?", "%#{param}%")
  end

  def self.tags_matches(param)
    matches('id', param)
  end


  def preliminary_data(molecule_name)
    return_hash = preliminary_request(molecule_name)
    if return_hash[:status]
      png_file_path = get_image(return_hash[:response_hash][:CID])
      png_file = File.open(png_file_path)
      self.cid = return_hash[:response_hash][:CID]
      self.molecular_weight = return_hash[:response_hash][:MolecularWeight]
      self.pubchem_link = "https://pubchem.ncbi.nlm.nih.gov/compound/#{self.cid}"
      self.preferred_abbreviation = png_file_path.gsub(/public/,"")
    end
  end

  def preliminary_cid_data(cid)
    return_hash = preliminary_cid_request(cid)
    if return_hash[:status]
      png_file_path = get_image(return_hash[:response_hash][:CID])
      png_file = File.open(png_file_path)
      self.cid = return_hash[:response_hash][:CID]
      self.molecular_weight = return_hash[:response_hash][:MolecularWeight]
      self.pubchem_link = "https://pubchem.ncbi.nlm.nih.gov/compound/#{self.cid}"
      self.preferred_abbreviation = png_file_path.gsub(/public/,"")
    end
  end

  def full_data(cid)
    unless self.display_name.present?
      self.display_name = property_request(cid, "IUPACName")
    end
    self.molecular_weight = property_request(cid, "MolecularWeight")
    self.sum_formular = property_request(cid, "MolecularFormula")
    self.charge = property_request(cid, "Charge")
    self.cano_smiles = property_request(cid, "CanonicalSMILES")
    self.iso_smiles = property_request(cid, "IsomericSMILES")
    self.iupac_name = property_request(cid, "IUPACName")
    self.inchikey = property_request(cid, "InChIKey")
    self.inchistring = property_request(cid, "InChI")
    self.volume_3d = property_request(cid, "Volume3D")
    self.tpsa = property_request(cid, "TPSA")
    self.x_log_p = property_request(cid, "XLogP")
    self.complexity = property_request(cid, "Complexity")
    self.h_bond_donor_count = property_request(cid, "HBondDonorCount")
    self.h_bond_acceptor_count = property_request(cid, "HBondAcceptorCount")
    self.atom_stereo_count = property_request(cid, "AtomStereoCount")
    self.bond_stereo_count = property_request(cid, "BondStereoCount")
    self.conformer_count_3d = property_request(cid, "ConformerCount3D")
    self.fingerprint_2d = property_request(cid, "Fingerprint2D")
  end


  def clip_png
    unless self.png.present?
      name = "app/assets/images/tmp/#{Time.new.to_i}_#{rand}"
      FileUtils.rm_rf(Dir['app/assets/images/tmp/*'])
      FileUtils.mkdir_p name
      png_file_path = "#{name}/compound.png"
      png_file = File.new(png_file_path, 'w')
      IO.copy_stream(open("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{self.cid}/png"), png_file_path)
      update(
        png:png_file
      )
    end
  end

  def auto_update
    if molecule_type == 'compound' && cid > 0
      full_data(cid)
      clip_png
      save
    end
  end

  def clip_protein_png
    unless self.png.present?
      if self.molecule_type == "protein"
        dir_path = get_protein_image(self.pdb_id) #change to pdb_id after migrations!
        png_file = File.open("#{dir_path}/protein.png")
        logger.debug png_file
        update(
          png: png_file
        )
      end
    end
  end


  def pdb_link
    if molecule_type == "protein" && pdb_id.present?
      return "https://www.rcsb.org/structure/#{pdb_id}"
    end
  end

  def pdb_info
    if self.molecule_type == "protein" && self.pdb_id.present?
      summary = self.pdb_summary_data(self.pdb_id)
      update(summary)
    end
  end

  def add_ertl_tpsa
    if molecule_type == 'compound'
      self.ertl_tpsa = ertl_TPSA(iso_smiles)
    end
  end

  def add_xlogP3
    if molecule_type == 'compound'
      self.cheng_xlogp3 = xlogP3(iso_smiles)
    end
  end

  def add_names
    self.names = names_request(self.cid)
    self.preferred_abbreviation = self.names.first
  end

  def add_cas
    self.cas = cas_request(self.cid)
  end

  def self.new_from_name(molecule_name)
    name = "app/assets/images/tmp/#{Time.new.to_i}_#{rand}"
    FileUtils.rm_rf(Dir['app/assets/images/tmp/*'])
    FileUtils.mkdir_p name
    png_file_path = "#{name}/compound.png"
    #mdl_file_path = "#{name}/compound.mdl"
    #svg_file_path = "#{name}/compound.svg"
    png_file = File.new(png_file_path, 'w')

    response = HTTP.get("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/#{molecule_name}/property/CanonicalSMILES,IsomericSMILES,InChI,InChIKey,IUPACName,MolecularFormula,MolecularWeight,XLogP,TPSA,Complexity,Charge,HBondDonorCount,HBondAcceptorCount,Volume3D,Fingerprint2D,ConformerCount3D,BondStereoCount,AtomStereoCount/json")
    response_hash = JSON.parse(response.to_s)['PropertyTable']['Properties'][0]
    if Molecule.where(cid: response_hash['CID']).present?
      'exist'
    else

      synonyms = HTTP.get("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{response_hash['CID']}/synonyms/json")
      synonyms_hash = JSON.parse(synonyms.to_s)['InformationList']['Information'][0]['Synonym']
      cas_response = HTTP.get("https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/#{response_hash['CID']}/JSON?heading=CAS")
      cas_hash = JSON.parse(cas_response.to_s)
      cas_string = cas_hash['Record']['Section'][0]['Section'][0]['Section'][0]['Information'][0]['Value']['StringWithMarkup'][0]['String']
      mdl_file = HTTP.get("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{response_hash['CID']}/SDF").to_s

      IO.copy_stream(open("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{response_hash['CID']}/png"), png_file_path)

      # File.write(mdl_file_path, mofile_2000_cut(mdl_file))
      # svg_file_tmp = iso_to_svg(response_hash["IsomericSMILES"])
      # svg_file_tmp = mdl_to_svg(mofile_2000_cut(mdl_file))
      # File.write(svg_file_path, svg_file_tmp)
      # File.write(png_file_path, png_file)
      # mdl_file_tmp_storage = File.open(mdl_file_path)
      # svg_file_tmp_storage = File.open(svg_file_path)
      # svg_file_tmp =
      create(inchikey: response_hash['InChIKey'],
             inchistring: response_hash['InChI'],
             cid: response_hash['CID'],
             molecular_weight: response_hash['MolecularWeight'],
             volume_3d: response_hash['Volume3D'],
             tpsa: response_hash['TPSA'],
             complexity: response_hash['Complexity'],
             sum_formular: response_hash['MolecularFormula'],
             names: synonyms_hash,
             iupac_name: response_hash['IUPACName'],
             display_name: synonyms_hash[0].downcase.capitalize,
             cas: cas_string,
             conformer_count_3d: response_hash['ConformerCount3D'],
             bond_stereo_count: response_hash['BondStereoCount'],
             atom_stereo_count: response_hash['AtomStereoCount'],
             h_bond_donor_count: response_hash['HBondDonorCount'],
             h_bond_acceptor_count: response_hash['HBondAcceptorCount'],
             x_log_p: response_hash['XLogP'],
             charge: response_hash['Charge'],
             cano_smiles: response_hash['CanonicalSMILES'],
             iso_smiles: response_hash['IsomericSMILES'],
             fingerprint_2d: response_hash['Fingerprint2D'],
             pubchem_link: "https://pubchem.ncbi.nlm.nih.gov/compound/#{response_hash['CID']}",
             png: png_file,
             mdl_string: mdl_file,
             preferred_abbreviation: synonyms_hash[0])
    end
    # FileUtils.rm_rf(name)
  rescue Exception => e
    nil
  end

  def self.new_from_cid(molecule_cid)
    if Molecule.where(cid: molecule_cid).present?
      'exist'
    else
      name = "app/assets/images/tmp/#{Time.new.to_i}_#{rand}"
      FileUtils.rm_rf(Dir['app/assets/images/tmp/*'])
      FileUtils.mkdir_p name
      png_file_path = "#{name}/compound.png"
      #mdl_file_path = "#{name}/compound.mdl"
      #svg_file_path = "#{name}/compound.svg"
      png_file = File.new(png_file_path, 'w')

      response = HTTP.get("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{molecule_cid}/property/CanonicalSMILES,IsomericSMILES,InChI,InChIKey,IUPACName,MolecularFormula,MolecularWeight,XLogP,TPSA,Complexity,Charge,HBondDonorCount,HBondAcceptorCount,Volume3D,Fingerprint2D,ConformerCount3D,BondStereoCount,AtomStereoCount/json")
      response_hash = JSON.parse(response.to_s)['PropertyTable']['Properties'][0]
      synonyms = HTTP.get("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{response_hash['CID']}/synonyms/json")
      synonyms_prehash = JSON.parse(synonyms.to_s)
      if synonyms_prehash['Fault'].present?
        compoundname = response_hash['IUPACName'].downcase.capitalize
        synonyms_hash = [compoundname]
      else
        synonyms_hash = JSON.parse(synonyms.to_s)['InformationList']['Information'][0]['Synonym']
        compoundname = synonyms_hash[0].downcase.capitalize
      end

      cas_response = HTTP.get("https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/#{response_hash['CID']}/JSON?heading=CAS")
      cas_hash = JSON.parse(cas_response.to_s)
      if cas_hash['Fault'].present?
        cas_string = nil
      else
        cas_string = cas_hash['Record']['Section'][0]['Section'][0]['Section'][0]['Information'][0]['Value']['StringWithMarkup'][0]['String']
      end
      mdl_file = HTTP.get("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{response_hash['CID']}/SDF").to_s

      IO.copy_stream(open("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{response_hash['CID']}/png"), png_file_path)

      # File.write(mdl_file_path, mofile_2000_cut(mdl_file))
      # svg_file_tmp = iso_to_svg(response_hash["IsomericSMILES"])
      # svg_file_tmp = mdl_to_svg(mofile_2000_cut(mdl_file))
      # File.write(svg_file_path, svg_file_tmp)
      # File.write(png_file_path, png_file)
      # mdl_file_tmp_storage = File.open(mdl_file_path)
      # svg_file_tmp_storage = File.open(svg_file_path)
      # svg_file_tmp =
      create(inchikey: response_hash['InChIKey'],
             inchistring: response_hash['InChI'],
             cid: response_hash['CID'],
             molecular_weight: response_hash['MolecularWeight'],
             volume_3d: response_hash['Volume3D'],
             tpsa: response_hash['TPSA'],
             complexity: response_hash['Complexity'],
             sum_formular: response_hash['MolecularFormula'],
             names: synonyms_hash,
             iupac_name: response_hash['IUPACName'],
             display_name: compoundname,
             cas: cas_string,
             conformer_count_3d: response_hash['ConformerCount3D'],
             bond_stereo_count: response_hash['BondStereoCount'],
             atom_stereo_count: response_hash['AtomStereoCount'],
             h_bond_donor_count: response_hash['HBondDonorCount'],
             h_bond_acceptor_count: response_hash['HBondAcceptorCount'],
             x_log_p: response_hash['XLogP'],
             charge: response_hash['Charge'],
             cano_smiles: response_hash['CanonicalSMILES'],
             iso_smiles: response_hash['IsomericSMILES'],
             fingerprint_2d: response_hash['Fingerprint2D'],
             pubchem_link: "https://pubchem.ncbi.nlm.nih.gov/compound/#{response_hash['CID']}",
             png: png_file,
             mdl_string: mdl_file,
             preferred_abbreviation: compoundname)
    end
  # FileUtils.rm_rf(name)
  rescue Exception => e
    nil
  end
end
