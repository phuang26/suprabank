module Pubchem


  #check the api itself
  def api_head_check
    url = "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastidentity/cid/2244/property/MolecularWeight/JSON"
    response = HTTP.head(url)
  end

  def response_time_check
    Benchmark.measure{api_head_check()}.total
  end


  def api_response_check
    head=api_head_check()
    if head.code == 200
      true
    end
  end

  def api_status_check
    if api_response_check()
      head=api_head_check()
      head=head.to_a[1]["X-Throttling-Control"]
    end
  end


  #requests
  def get_cid_mw(name)
    url="https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/#{name}/property/MolecularWeight/JSON"
    if api_response_check()
      response = HTTP.get(url)
    end

    if response.code == 200
      response_body = JSON.parse(response.to_s).deep_symbolize_keys
    else
      response.code
    end

  end

  def molecule_presence(cid)
    Molecule.where(cid:cid).present?
  end

  def additive_presence(cid)
    Additive.where(cid:cid).present?
  end

  def solvent_presence(cid)
    Solvent.where(cid:cid).present?
  end


  def preliminary_request(molecule_name)
    if api_response_check()
      response_body = get_cid_mw(molecule_name)
      if response_body.class == Hash
        response_hash = response_body[:PropertyTable][:Properties][0]
        if Molecule.where(cid: response_hash[:CID]).present?
          status=true
          msg='exist'
        else
          status = true
          msg = "Request full record by CID: #{response_hash[:CID]}"
        end
      end
    else
      status = false
      msg = "PubChem is not available"
      response_hash = {}
    end
    return_hash = {status: status, msg: msg, response_hash: response_hash}
  end

  def preliminary_cid_request(cid)
    if api_response_check()
      url="https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastidentity/cid/#{cid}/property/MolecularWeight/JSON"
      response = HTTP.get(url)
      if response.code == 200
        response_body = JSON.parse(response.to_s).deep_symbolize_keys
        response_hash = response_body[:PropertyTable][:Properties][0]
        if Molecule.where(cid: response_hash[:CID]).present?
          status=true
          msg='exist'
        else
          status = true
          msg = "Request full record by CID: #{response_hash[:CID]}"
        end
      end
    else
      status = false
      msg = "PubChem is not available"
      response_hash = {}
    end
    return_hash = {status: status, msg: msg, response_hash: response_hash}
  end





  def get_image(cid)
    name = "public/images/tmp/#{Time.new.to_i}_#{rand}"
    FileUtils.rm_rf(Dir['public/images/tmp/*'])
    FileUtils.mkdir_p name
    png_file_path = "#{name}/compound.png"
    png_file = File.new(png_file_path, 'w')
    url="https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastidentity/cid/#{cid}/png"
    IO.copy_stream(open(url), png_file_path)
    return png_file_path
  end


  def full_record_json(cid)
    url="https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastidentity/cid/#{cid}/JSON"
    response = HTTP.get(url)
    if response.code == 200
      response_body = JSON.parse(response.to_s).deep_symbolize_keys
    else
      response.code
    end
  end

  def property_request(cid, property)
    url="https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastidentity/cid/#{cid}/property/#{property}/JSON"
    response = HTTP.get(url)
    if response.code == 200
      response_body = JSON.parse(response.to_s).deep_symbolize_keys
      response_hash = response_body[:PropertyTable][:Properties][0][property.to_sym]
    else
      nil
    end
  end

  def names_request(cid)
    url="https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastidentity/cid/#{cid}/synonyms/JSON"
    response = HTTP.get(url)
    if response.code == 200
      synonyms_array = JSON.parse(response.to_s)['InformationList']['Information'][0]['Synonym']
    else
      synonyms_array = [nil]
    end
  end

  def cas_request(cid)
    url="https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/fastidentity/compound/#{cid}/JSON?heading=CAS"
    response = HTTP.get(url)
      if response.code == 200
        cas_hash = JSON.parse(response.to_s)
        cas_string = cas_hash['Record']['Section'][0]['Section'][0]['Section'][0]['Information'][0]['Value']['StringWithMarkup'][0]['String']
    else
      cas_string = nil
    end
  end




  def entries_by_formula(formula)
    url="https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastformula/#{formula}/cids/JSON"
    if api_response_check()
      response = HTTP.get(url)
    end

    if response.code == 200
      response_body = JSON.parse(response.to_s).deep_symbolize_keys
      cid_array = response_body[:IdentifierList][:CID]
    else
      cid_array = []
    end


  end

  def entries_by_smiles(smiles)
    url="https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastidentity/smiles/#{smiles}/cids/JSON"
    if api_response_check()
      response = HTTP.get(url)
    end

    if response.code == 200
      response_body = JSON.parse(response.to_s).deep_symbolize_keys
      cid_array = response_body[:IdentifierList][:CID]
    else
      cid_array = []
    end

  end

  def entries_by_cid(cid)
    url="https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastidentity/cid/#{cid}/cids/JSON"
    if api_response_check()
      response = HTTP.get(url)
    end

    if response.code == 200
      response_body = JSON.parse(response.to_s).deep_symbolize_keys
      cid_array = response_body[:IdentifierList][:CID]
    else
      cid_array = []
    end

  end

  def entries_by_name(name)
    url="https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/#{name}/cids/JSON"
    if api_response_check()
      response = HTTP.get(url)
    end

    if response.code == 200
      response_body = JSON.parse(response.to_s).deep_symbolize_keys
      cid_array = response_body[:IdentifierList][:CID]
    else
      cid_array = []
    end

  end

  def entry_update
    array = []
    if self.cid.present?
      array += entries_by_cid(self.cid)
    end
    if self.iso_smiles.present?
      array += entries_by_smiles(self.iso_smiles)
    end
    if self.sum_formular.present?
      array += entries_by_formula(self.sum_formular)
    end
    if self.display_name.present?
      array += entries_by_name(self.display_name)
    end
    return array.uniq

  end


  def preliminary_update_request(array)
    results = []
    hash = {cid: nil, iso_smiles: nil, sum_formular: nil, display_name: nil}
    array.each do |cid|
      result = [
        cid,
        property_request(cid, "IsomericSMILES"),
        property_request(cid, "MolecularFormula"),
        property_request(cid, "IUPACName")
      ]
      results.append result
    end
    return results
  end

end
