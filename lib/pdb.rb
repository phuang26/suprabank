module PDB

  require 'uri'
  require 'net/http'
  require 'openssl'
  require 'json'
  require 'http'


  def pdb_data_by_id(pdb_id)
    if pdb_id.present?
      url = URI(URI.encode("https://data.rcsb.org/rest/v1/core/entry/#{pdb_id}"))
    end
    begin
      response = HTTP.get(url)
      response_headers = Hash(response.headers).symbolize_keys
      response_body = JSON.parse(response.to_s).deep_symbolize_keys
        return response_body
    rescue StandardError  => e
    end

  end

  def valid_pdb_id?(pdb_id)
    hash=pdb_data_by_id(pdb_id)
    unless hash[:status].present?
      return true
    else
      return false
    end
  end

  def pdb_summary_data(pdb_id)
    hash = pdb_data_by_id(pdb_id)
    summary = {
      molecule_type: "protein",
      molecular_weight: (hash[:rcsb_entry_info][:molecular_weight].to_f)*1000,
      total_structure_weight: hash[:rcsb_entry_info][:molecular_weight],
      atom_count: hash[:rcsb_entry_info][:deposited_atom_count],
      residue_count: hash[:rcsb_entry_info][:deposited_modeled_polymer_monomer_count],
      pdb_descriptor: hash[:struct][:pdbx_descriptor],
      pdb_title: hash[:struct][:title],
      pdb_keywords: hash[:struct_keywords][:pdbx_keywords],
      pdb_id: hash[:rcsb_id]
    }
    return summary
  end

  def preliminary_pdb_data(pdb_id)
    if valid_pdb_id?(pdb_id)
      hash = {preferred_abbreviation: get_protein_image(pdb_id)}
      return hash.merge(pdb_summary_data(pdb_id))
    else
      return pdb_data_by_id(pdb_id)
    end
  end


  def get_pdb_file(pdb_id)
    begin
    dir_path = "public/images/tmp/#{pdb_id}"
    FileUtils.rm_rf(Dir['public/images/tmp/*'])
    FileUtils.mkdir_p dir_path
    pdb_file_path = "#{dir_path}/protein.pdb"
    pdb_file = File.new(pdb_file_path, 'w')

    url="https://files.rcsb.org/download/#{pdb_id}.pdb"
    IO.copy_stream(open(url), pdb_file_path)
    return dir_path
    rescue => e
    end
  end


  def get_protein_image(pdb_id)
    dir_path = get_pdb_file(pdb_id)
    `cp lib/png_from_pdb.py #{dir_path} && cd #{dir_path} && pymol protein.pdb png_from_pdb.py -qc` #the -c flag stands for command-line only to suppress GUI
    return dir_path
  end

  def protein_presence?(pdbid)
    Molecule.where("lower(pdb_id) = ?", pdbid.downcase).present?
  end

end
