module Datacite
  include Colors
  require 'uri'
  require 'net/http'
  require 'openssl'
  require 'json'

include Rails.application.routes.url_helpers





def generate_affiliation(cooperator)
  hash = {affiliation:
    [{
    name: cooperator[:affiliation],
    schemeURI: "https://ror.org/",
    affiliationIdentifier: cooperator[:affiliationIdentifier],
    affiliationIdentifierScheme: "ROR"
    }]
  }


    return hash
end

def generate_identifier(cooperator)
  hash = {
    nameIdentifiers: [
    {
    nameIdentifier: cooperator[:nameIdentifier],
    nameIdentifierScheme: "ORCID",
    schemeURI: "http://orcid.org"
    }]
  }
  return hash
end


def generate_cooperators(cooperators)
  array = []
  cooperators = cooperators.to_a
  cooperators.each {|cooperator|
    hash = {
      nameType: "Personal",
      name: nil,
      givenName: nil,
      familyName: nil,
      affiliation: nil
    }
    cooperator_hash = cooperator.attributes.symbolize_keys
    hash.each_key{|k| hash[k] = cooperator_hash[k]}
    hash.merge!(generate_identifier(cooperator))
    hash.merge!(generate_affiliation(cooperator))
    array.append(hash)
  }
  return array
end

def generate_contributors(cooperators, dataset)
  array = []
  cooperators = cooperators.to_a
  cooperators.each {|cooperator|
    hash = {
      nameType: "Personal",
      contributorName: nil,
      givenName: nil,
      familyName: nil,
      affiliation: nil,
      contributorType: "DataManager"
    }
    cooperator_hash = cooperator.attributes.symbolize_keys
    hash.each_key{|k| hash[k] = cooperator_hash[k]}
    hash[:contributorType] = cooperator.dataset_contributors.where(dataset: dataset)&.first&.contributorType
    hash.merge!(generate_identifier(cooperator))
    hash.merge!(generate_affiliation(cooperator))
    array.append(hash)
  }
  return array
end




  def convert_dataset_model(model, event)
    #logger.debug "Inside DataCite convert_dataset_model method, The dsri attributes is: #{model.dataset_related_identifiers.first.attributes}"
    logger.debug "Inside DataCite convert_dataset_model method, The dsri attributes is: #{related_identifiers.first.present?}"
    data_hash =
    {
      data: {
        attributes: {
          identifiers: [
            {
            identifier: model.identifier,
            identifierType: model.identifierType
            }
          ],
          alternateIdentifiers: [
            {
            alternateIdentifier: model.alternateIdentifier,
            alternateIdentifierType: model.alternateIdentifierType
            }
          ],
          creators: generate_cooperators(model.creators),
          contributors: generate_contributors(model.contributors, model),
          titles: [
            {
              title: model.title,
              lang: model.language
            }
          ],
          descriptions: [
            {
              description: model.description,
              descriptionType: model.descriptionType
            }
          ],
          types: {
            resourceTypeGeneral: model.resourceTypeGeneral,
            resourceType: model.resourceType
          },
          relatedIdentifiers: [
            if model.related_identifiers.first.present?
              {
                relatedIdentifier: model.related_identifiers.first.relatedIdentifier,
                relatedIdentifierType: model.related_identifiers.first.relatedIdentifierType,
                relationType: model.dataset_related_identifiers.first.relationType
              }
            else
              {}
            end
          ],
          landingPage: {
            url: model.alternateIdentifier,
            contentType: model.format
          },
          rightsList: [
            {
              rights: "Creative Commons Attribution Share Alike 4.0 International",
              rightsUri: "https://creativecommons.org/licenses/by-sa/4.0/legalcode",
              schemeUri: "https://spdx.org/licenses/",
              rightsIdentifier: "cc-by-sa-4.0",
              rightsIdentifierScheme: "SPDX"
            }
          ],
          formats: [model.format],
          sizes: [model.size],
          language: model.language,
          doi: model.identifier,
          url: model.alternateIdentifier,
          event: event,
          publisher: model.publisher,
          publicationYear: model.publicationYear,
          schemaVersion: "http://datacite.org/schema/kernel-4",
        }
      }
    }

  end

  def update_entry(model, request_type, event)
    #logger.debug "Inside DataCite module, The dsri attributes is: #{model.dataset_related_identifiers.first.attributes}"
    data_hash = convert_dataset_model(model, event)
    logger.debug data_hash
    #    .id is a required property
    #['attributes - doi - creators - titles - publisher - publicationYear'] is a required property

    #event = ["hide", "register", "publish"]
    #state = ["draft", "registered", "finable"]
    #isActive = [false, false, true]


    authorization = ENV['DCAUTH'] #test prefix: 10.80821

    base_url = ENV['DCBASEURL']

    case request_type
    when "Post"
      url = URI(base_url)
      request = Net::HTTP::Post.new(url)
    when "Get"
      url = URI("#{base_url}/#{model.identifier}")
      request = Net::HTTP::Get.new(url)
    when "Put"
      url = URI("#{base_url}/#{model.identifier}")
      request = Net::HTTP::Put.new(url)
    when "Delete"
      url = URI("#{base_url}/#{model.identifier}")
      request = Net::HTTP::Delete.new(url)
    end

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request["Content-Type"] = 'application/vnd.api+json'
    request["Authorization"] = "Basic #{authorization}"

    request.body = data_hash.to_json
    response = http.request(request)
    if response.present?
      unless response.code == "204"
        return JSON.parse(response.read_body)
      end
    end

  end




  def json2bib
    if datacite.present? && datacite["data"].present?
      type = datacite["data"]["attributes"]["types"]["bibtex"]
      authors = creators.map{|c| "#{c.familyName}, #{c.givenName}" }
      authors_str = ""
      authors.each_with_index {|a, index| (index == authors.size - 1) ? authors_str += a : authors_str += a + " and "}
      doi_url = "https://doi.org/"+identifier
      target = ENV["ENVURL"] + "/datasets/#{id}"
      str = "@#{type}{#{doi_url},
      doi = {#{identifier}},
      url = {#{target}},
      author = {#{authors_str}},
      title = {#{title}},
      publisher = {SupraBank},
      year = {#{publicationYear}},
      copyright = {#{rights}}
      }"
      return str
    end
  end




  def clip_bibtex
    puts cyan __method__
    if datacite.present? && datacite["data"].present?
      pn = Pathname(Time.now.strftime("%Y_%m_%d_%H_%M_%S"))
      dir_path = "public/tmp/citation/#{pn.basename}"
      puts "dir path: #{dir_path}"
      bib_file_path = "#{dir_path}/doi.bib"
      begin
        FileUtils.mkdir_p dir_path
        puts "bib_file_path: #{bib_file_path}"
        File.write(bib_file_path, json2bib)
        self.bibtex = File.open(bib_file_path)
        FileUtils.rm_rf(dir_path)
      rescue StandardError => e
        puts red e
      end
    end
  end


  def abbrev_name(name)
    names = name.split(" ")
    authors_str = ""
    names.each_with_index{|a, index| (index == names.size - 1) ? authors_str += a[0] + "." : authors_str+=a[0] + ". "}
    return authors_str
  end


  def json2citation
    puts cyan __method__
    if datacite.present? && datacite["data"].present?
      dcatttributes = datacite["data"]["attributes"]
      citation_str = ""
      authors = creators.each{|c| citation_str += "#{abbrev_name(c.givenName)} #{c.familyName}, " }
      citation_str += "<i>SupraBank</i> <b>#{dcatttributes["publicationYear"]}</b>, <i>#{dcatttributes["titles"][0]["title"]}</i> (dataset). #{"https://doi.org/" + identifier}"
      self.citation = citation_str
      return citation_str
    end
  end



end
