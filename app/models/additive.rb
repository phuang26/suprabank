class Additive < ActiveRecord::Base
  acts_as_taggable_on :tags
  validates :cid, presence: true, uniqueness: true
  validates :display_name, presence: true, uniqueness: {case_sensitive: false}
  has_many :interaction_additives
  has_many :interactions, through: :interaction_additives
  has_many :framework_molecule_additives
  has_many :framework_molecules, through: :framework_molecule_additives
  has_attached_file :svg, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :svg, content_type: /\Aimage\/.*\z/
  has_attached_file :png
  validates_attachment_content_type :png, content_type: /\Aimage\/.*\z/
  after_save :cache_interactions, :cache_png_url

  include Pubchem
  include PgSearch
    pg_search_scope :search_by_title,
                    against: [:display_name, :iupac_name],
                    using: {
                      tsearch: {dictionary: "english",
                                any_word: true,
                                prefix: true}
                    }

    pg_search_scope :search_by_names,
                  against: :names,
                  using: {
                    tsearch: {dictionary: "english",
                              any_word: true,
                              prefix: true}
                  }



  def cache_interactions
    self.update_column(:interactions_count, self.interactions.count)
  end
  
  def cache_png_url
    self.update_column(:png_url, self.png.url)
  end

  def self.dbsearch(param)
    param.strip!
    param.downcase!
    to_send_back = (display_name_matches(param) + iupac_name_matches(param) + search_by_names(param) + search_by_title(param)).uniq
    return nil unless to_send_back
    to_send_back
  end

  def self.id_matches(param)
    matches('id', param)
  end

  def self.display_name_matches(param)
    matches('display_name', param)

  end

  def self.iupac_name_matches(param)
    matches('iupac_name', param)

  end

  def self.matches(field_name, param)
    Additive.where("#{field_name} like ?", "%#{param}%")
  end

  def self.new_from_name(additive_name)

    begin
    name="app/assets/images/tmp/#{Time.new.to_i.to_s}_#{rand.to_s}"
    FileUtils.rm_rf(Dir["app/assets/images/tmp/*"])
    FileUtils.mkdir_p name
    png_file_path = "#{name}/compound.png"
    mdl_file_path = "#{name}/compound.mdl"
    svg_file_path = "#{name}/compound.svg"
    png_file = File.new(png_file_path,'w')

    response = HTTP.get("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/#{additive_name}/property/CanonicalSMILES,IsomericSMILES,InChI,InChIKey,IUPACName,MolecularFormula,MolecularWeight,XLogP,TPSA,Complexity,Charge,HBondDonorCount,HBondAcceptorCount,Volume3D,Fingerprint2D,ConformerCount3D,BondStereoCount,AtomStereoCount/json")
    response_hash = JSON.parse(response.to_s)["PropertyTable"]["Properties"][0]
    unless Additive.where(cid:response_hash["CID"]).present?

      synonyms = HTTP.get("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{response_hash["CID"]}/synonyms/json")
      synonyms_hash = JSON.parse(synonyms.to_s)["InformationList"]["Information"][0]["Synonym"]
      cas_response = HTTP.get("https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/#{response_hash["CID"]}/JSON?heading=CAS")
      cas_hash =  JSON.parse(cas_response.to_s)
      cas_string = cas_hash["Record"]["Section"][0]["Section"][0]["Section"][0]["Information"][0]["Value"]["StringWithMarkup"][0]["String"]
      mdl_file = HTTP.get("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{response_hash["CID"]}/SDF").to_s

      IO.copy_stream(open("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{response_hash["CID"]}/png"), png_file_path)


      create(inchikey: response_hash["InChIKey"],
          inchistring: response_hash["InChI"],
          cid: response_hash["CID"],
          molecular_weight: response_hash["MolecularWeight"],
          volume_3d: response_hash["Volume3D"],
          tpsa: response_hash["TPSA"],
          complexity: response_hash["Complexity"],
          sum_formular: response_hash["MolecularFormula"],
          names: synonyms_hash,
          iupac_name: response_hash["IUPACName"],
          display_name: synonyms_hash[0].downcase.capitalize,
          cas: cas_string,
          conformer_count_3d: response_hash["ConformerCount3D"],
          bond_stereo_count: response_hash["BondStereoCount"],
          atom_stereo_count: response_hash["AtomStereoCount"],
          h_bond_donor_count: response_hash["HBondDonorCount"],
          h_bond_acceptor_count: response_hash["HBondAcceptorCount"],
          x_log_p: response_hash["XLogP"],
          charge: response_hash["Charge"],
          cano_smiles: response_hash["CanonicalSMILES"],
          iso_smiles: response_hash["IsomericSMILES"],
          fingerprint_2d: response_hash["Fingerprint2D"],
          pubchem_link: "https://pubchem.ncbi.nlm.nih.gov/compound/#{response_hash["CID"]}",
          png: png_file,
          mdl_string: mdl_file,
          preferred_abbreviation: synonyms_hash[0]
       )
   else
     return 'exist'
   end
     #FileUtils.rm_rf(name)

     rescue Exception => e
       return nil

    end
  end

    def self.new_from_cid(additive_cid)

      begin
      unless Additive.where(cid:additive_cid).present?
        name="app/assets/images/tmp/#{Time.new.to_i.to_s}_#{rand.to_s}"
        FileUtils.rm_rf(Dir["app/assets/images/tmp/*"])
        FileUtils.mkdir_p name
        png_file_path = "#{name}/compound.png"
        mdl_file_path = "#{name}/compound.mdl"
        svg_file_path = "#{name}/compound.svg"
        png_file = File.new(png_file_path,'w')

        response = HTTP.get("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{additive_cid}/property/CanonicalSMILES,IsomericSMILES,InChI,InChIKey,IUPACName,MolecularFormula,MolecularWeight,XLogP,TPSA,Complexity,Charge,HBondDonorCount,HBondAcceptorCount,Volume3D,Fingerprint2D,ConformerCount3D,BondStereoCount,AtomStereoCount/json")
        response_hash = JSON.parse(response.to_s)["PropertyTable"]["Properties"][0]
        synonyms = HTTP.get("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{response_hash["CID"]}/synonyms/json")
        synonyms_prehash = JSON.parse(synonyms.to_s)
        unless synonyms_prehash["Fault"].present?
          synonyms_hash = JSON.parse(synonyms.to_s)["InformationList"]["Information"][0]["Synonym"]
          compoundname = synonyms_hash[0].downcase.capitalize
        else
          compoundname = response_hash["IUPACName"].downcase.capitalize
          synonyms_hash = [compoundname]
        end

        cas_response = HTTP.get("https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/#{response_hash["CID"]}/JSON?heading=CAS")
        cas_hash =  JSON.parse(cas_response.to_s)
        unless cas_hash["Fault"].present?
          cas_string = cas_hash["Record"]["Section"][0]["Section"][0]["Section"][0]["Information"][0]["Value"]["StringWithMarkup"][0]["String"]
        else
          cas_string = nil
        end
        mdl_file = HTTP.get("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{response_hash["CID"]}/SDF").to_s

        IO.copy_stream(open("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{response_hash["CID"]}/png"), png_file_path)


        create(inchikey: response_hash["InChIKey"],
            inchistring: response_hash["InChI"],
            cid: response_hash["CID"],
            molecular_weight: response_hash["MolecularWeight"],
            volume_3d: response_hash["Volume3D"],
            tpsa: response_hash["TPSA"],
            complexity: response_hash["Complexity"],
            sum_formular: response_hash["MolecularFormula"],
            names: synonyms_hash,
            iupac_name: response_hash["IUPACName"],
            display_name: compoundname,
            cas: cas_string,
            conformer_count_3d: response_hash["ConformerCount3D"],
            bond_stereo_count: response_hash["BondStereoCount"],
            atom_stereo_count: response_hash["AtomStereoCount"],
            h_bond_donor_count: response_hash["HBondDonorCount"],
            h_bond_acceptor_count: response_hash["HBondAcceptorCount"],
            x_log_p: response_hash["XLogP"],
            charge: response_hash["Charge"],
            cano_smiles: response_hash["CanonicalSMILES"],
            iso_smiles: response_hash["IsomericSMILES"],
            fingerprint_2d: response_hash["Fingerprint2D"],
            pubchem_link: "https://pubchem.ncbi.nlm.nih.gov/compound/#{response_hash["CID"]}",
            png: png_file,
            mdl_string: mdl_file,
            preferred_abbreviation: compoundname
         )
       else
         return 'exist'
       end
       #FileUtils.rm_rf(name)

       rescue Exception => e
         return nil

      end
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

    def add_names
      self.names = names_request(self.cid)
      self.preferred_abbreviation = self.names.first
    end

    def add_cas
      self.cas = cas_request(self.cid)
    end

end
