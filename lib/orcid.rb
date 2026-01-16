module Orcid

  require 'uri'
  require 'net/http'
  require 'openssl'
  require 'json'
  require 'http'


  def query_orcid_by_name(family_name, given_name="")
    #logger.debug "#{family_name}"
    if given_name.present?
      url = URI(URI.encode("https://pub.orcid.org/v3.0/search/?q=family-name:#{family_name}+AND+given-names:#{given_name}"))
    else
      url = URI(URI.encode("https://pub.orcid.org/v3.0/search/?q=family-name:#{family_name}"))
    end

    HTTP.auth("Bearer e8cd658c-fec4-4b0d-b4c7-f5ecf1ef1036")
    response = HTTP.get(url)
    response_headers = Hash(response.headers).symbolize_keys
    if response.code == 200
      response_body = Hash.from_xml(response.to_s).symbolize_keys
      num = response_body[:search]["num_found"].to_i
      array = []
        if num > 0
          results = response_body[:search]["result"]
          if num > 1
            for result in results
              array.append(result["orcid_identifier"]["path"])
            end
          else
            array.append(results["orcid_identifier"]["path"])
          end
        else
          array = [""]
        end
      return array
    else
      return "Error #{response.code} occured"
    end

  end


  def get_name_hash_from_id(id)

    url = URI("https://pub.orcid.org/v2.1/#{id}/person")
    HTTP.auth("Bearer e8cd658c-fec4-4b0d-b4c7-f5ecf1ef1036")
    response = HTTP.get(url)
    response_headers = Hash(response.headers).symbolize_keys
    if response.code == 200
      response_body = Hash.from_xml(response.to_s).symbolize_keys
      name_hash = response_body[:person]["name"].symbolize_keys
      return name_hash
    else
      return "Error #{response.code} occured"
    end

  end

  def get_hashed_name_array(array)
    hashed_name_array = []
    for id in array do
      if id.present?
        hashed_name_array.append(get_name_hash_from_id(id))
      end
    end
    return hashed_name_array
  end


  def get_name_array(array)
    hashed_name_array = get_hashed_name_array(array)
    name_array = hashed_name_array.map{|n| [n[:given_names], n[:family_name], n[:path]]}
    return name_array
  end


  def query_name_array_from_name(family_name, given_name)
    a = query_orcid_by_name(family_name, given_name)
    if a.kind_of?(Array)
      names = get_name_array(a)
    else
      names = []
    end
    return names
  end

  def get_full_employment_hash(id)
    url = URI("https://pub.orcid.org/v2.1/#{id}/employments")
    HTTP.auth("Bearer e8cd658c-fec4-4b0d-b4c7-f5ecf1ef1036")
    response = HTTP.get(url)
    if response.code == 200
      response_body = Hash.from_xml(response.to_s).symbolize_keys
      return response_body
    else
      return "Error #{response.code} occured"
    end
  end


  def get_employment_hash_from_id(id)
    url = URI("https://pub.orcid.org/v2.1/#{id}/employments")
    HTTP.auth("Bearer e8cd658c-fec4-4b0d-b4c7-f5ecf1ef1036")
    response = HTTP.get(url)
    response_headers = Hash(response.headers).symbolize_keys
    if response.code == 200
      response_body = Hash.from_xml(response.to_s).symbolize_keys[:employments]["employment_summary"]
      unless response_body.nil?
        if response_body.is_a? Hash
          employment_hash = response_body.symbolize_keys
        elsif response_body.is_a? Array
          employment_hash = response_body[0].symbolize_keys
        end
      else
        employment_hash = {source: {"source_name" => "no employments", "source_orcid" => {"path" => "no employments"}}, organization: {"name" => "no employments"}}
      end
      return employment_hash
    else
      return "Error #{response.code} occured"
    end
  end

  def get_hashed_employment_array(array)
    hashed_employment_array = []
    for id in array do
      if id.present?
        hashed_employment_array.append(get_employment_hash_from_id(id))
      end
    end
    return hashed_employment_array
  end


  def get_employment_array(array)
    hashed_employment_array = get_hashed_employment_array(array)
    employment_array = hashed_employment_array.map{|n| [n[:source]["source_name"], n[:organization]["name"], n[:source]["source_orcid"]["path"]]}
    return employment_array
  end

  def query_employment_array_from_name(family_name, given_name)
    a = query_orcid_by_name(family_name, given_name)
    employments = get_employment_array(a[0,6])
  end




  def automatic_orcid_assignment
    unless nameIdentifier.present?
      begin
        Timeout::timeout(15) do
          a = query_name_array_from_name(familyName, givenName.split(" ")[0])
          if a.length == 1 && (a[0][0] == givenName.split(" ")[0] ) && (a[0][1] == familyName)
            self.nameIdentifier = a[0][2]
            return a
          end
        end
      rescue StandardError => e
        return e
      end
    end
  end


  #
  # def update_entry(model, request_type, event)
  #   data_hash = convert_dataset_model(model)
  #   data_hash[:data][:attributes][:event] = "hide"
  #
  #   case request_type
  #   when "Post"
  #     url = URI("https://api.datacite.org/dois")
  #     request = Net::HTTP::Post.new(url)
  #   when "Put"
  #     url = URI("https://api.datacite.org/dois/#{model.identifier}")
  #     request = Net::HTTP::Put.new(url)
  #   when "Delete"
  #     url = URI("https://api.datacite.org/dois/#{model.identifier}")
  #     request = Net::HTTP::Delete.new(url)
  #   end
  #
  #   http = Net::HTTP.new(url.host, url.port)
  #   http.use_ssl = true
  #   http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  #
  #   request["content-type"] = 'application/vnd.api+json'
  #   request["authorization"] = 'Basic VElCLlNVUFJBQkFOSzojXDl8S3AzODNFTDs2NQ=='
  #
  #   request.body = data_hash.to_json
  #   response = http.request(request)
  #   puts response.read_body
  #
  # end

end
