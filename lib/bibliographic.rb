module Bibliographic

  include Colors
  require 'uri'
  require 'net/http'
  require 'openssl'
  require 'json'
  require 'http'

def self.doi_extractor(doi)
  doi = doi.gsub(/http:\/\/doi.org\//,"")
  doi = doi.gsub(/https:\/\/doi.org\//,"")
  return doi
end


def doi_request(doi)
  if doi.present?
      #doi_safe=doi.strip.gsub(/[^0-9A-Za-z^\/.-]/){|char| "%"+char.ord.to_s(16)}
      doi_safe = URI.encode(doi.strip.gsub(/https:\/\/doi.org\//,""))
      begin
        hash = Serrano.registration_agency(ids: doi_safe)[0].deep_symbolize_keys
      rescue StandardError => e
        hash = {status: "bad"}
      end
      if hash[:status] == "ok"
        puts "will use Serrano"
        json = Serrano.content_negotiation(ids: doi_safe, format: "citeproc-json")
        if json == "Resource not found."
          puts "will use direct crossref api"
          hash=Bibliographic.crossref_api(doi)
          if hash[:status] == "ok"
            csl_hash = hash[:message]
          end
        else
          csl_hash = json && json.length >= 2 ? JSON.parse(json) : nil
        end
      else
        puts "will use direct crossref api"
        hash=Bibliographic.crossref_api(doi)
        if hash[:status] == "ok"
          csl_hash = hash[:message]
        end
      end
      return csl_hash
  end
end

def doi_bibtex(doi)
  if doi.present?
    doi_safe=doi.strip.gsub(/[^0-9A-Za-z^\/.-]/){|char| "%"+char.ord.to_s(16)}
    #doi_safe=URI.encode(doi.strip)
    url = "https://doi.org/#{doi_safe}"
    response = HTTP[accept: "text/bibliography; style=bibtex"].follow.get(url)
    if response.code == 200
      pn = Pathname(Time.now.strftime("%Y_%m_%d_%H_%M_%S"))
      dir_path = "public/tmp/citation/#{pn.basename}"
      FileUtils.rm_rf(Dir['public/tmp/citation/*'])
      FileUtils.mkdir_p dir_path
      bib_file_path = "#{dir_path}/doi.bib"
      `cd #{dir_path} && curl -L -H "Accept: text/bibliography; style=bibtex" #{url} > doi.bib`
    end
    return bib_file_path
  end
end

def bib_to_ris(bibtex_path, doi)
  if bibtex_path.present?
    doi_safe=doi.strip.gsub(/[^0-9A-Za-z^\/.-]/){|char| "%"+char.ord.to_s(16)}
    pn = Pathname(doi_safe)
    dir_path = "public/tmp/ris/#{pn.basename}"
    FileUtils.rm_rf(Dir['public/tmp/ris/*'])
    FileUtils.mkdir_p dir_path
    bib_file_path = "#{dir_path}/input.bib"
    ris_file_path = "#{dir_path}/output.ris"
    `cd #{dir_path} && cp #{bibtex_path} input.bib && bib2xml input.bib | xml2ris > output.ris`
  end
    return ris_file_path
end

def bib_to_enw(bibtex_path, doi)
  if bibtex_path.present?
    doi_safe=doi.strip.gsub(/[^0-9A-Za-z^\/.-]/){|char| "%"+char.ord.to_s(16)}
    pn = Pathname(doi_safe)
    dir_path = "public/tmp/enw/#{pn.basename}"
    FileUtils.rm_rf(Dir['public/tmp/enw/*'])
    FileUtils.mkdir_p dir_path
    bib_file_path = "#{dir_path}/input.bib"
    enw_file_path = "#{dir_path}/output.enw"
    `cd #{dir_path} && cp #{bibtex_path} input.bib && bib2xml input.bib | xml2end > output.enw`
  end
    return enw_file_path
end


def pdf_link(crossref_hash)
  pdf_publishers=["Springer", "RSC", "ACS"]
  tdm_publishers=["Wiley", "Elsevier BV"]
  if pdf_publishers.any? {|word| crossref_hash["publisher"].include?(word)}
    link = crossref_hash.dig('link', 0, 'URL')
    
  # elsif tdm_publishers.any? {|word| crossref_hash["publisher"].include?(word)}
  #   case crossref_hash["publisher"]
  #   when "Wiley"
  #     link =
  #   when "Elsevier BV"
  #     link =
  #   end
  else
    link = nil
  end
  return link
end

def valid_reference_doi?(doi)
      #doi_safe = doi.strip.gsub(/https:\/\/doi.org\//,"")
      doi_safe = Bibliographic.doi_extractor(doi)
       Rails.logger.debug doi_safe
      #doi_safe = doi_safe.gsub(/[^0-9A-Za-z^\/.-]/){|char| "%"+char.ord.to_s(16)}
      begin
        hash = Serrano.registration_agency(ids: URI.encode(doi_safe))[0].deep_symbolize_keys
      rescue Serrano::NotFound  => e
        hash = "Record not found."
      rescue StandardError  => e
        hash = "Some other error"
      end
      unless hash.class == Hash
        begin
          hash = Bibliographic.crossref_api(doi)[:message]
        rescue StandardError  => e
          hash = "Some other error"
        end
      end
  return (hash.class == Hash)
end


def self.crossref_api(doi)
  #doi_safe = doi.strip.gsub(/https:\/\/doi.org\//,"")
  doi_safe = Bibliographic.doi_extractor(doi)
  url = "https://api.crossref.org/works/#{doi_safe}"
  response = HTTP.get(url)
  response_hash = JSON.parse(response.to_s)
  result = response_hash.symbolize_keys
end

def citation_renderer(csl_hash)
  cp = CiteProc::Processor.new style: 'angewandte-chemie', format: 'html'
  cp.import [csl_hash]
  rendered_citation = cp.render :bibliography, id: ""
  #Angewandte Chemie International Edition
  render_result = rendered_citation[0].gsub(/\[/,"").gsub(/\]/,"").gsub(/\"/,"")
  render_result = render_result.gsub(/Angewandte Chemie International Edition/,"Angew. Chem. Int. Ed.")
  return render_result
end


def meta_data_retriever
  puts cyan __method__
  if relatedIdentifier.present? && relatedIdentifierType == 'DOI'
    doi = relatedIdentifier
    pn = Pathname(Time.now.strftime("%Y_%m_%d_%H_%M_%S"))
    dir_path = "public/tmp/html/#{pn.basename}"
    html_file_path = "#{dir_path}/meta.html"
    begin
      FileUtils.mkdir_p dir_path
      puts "html_file_path: #{html_file_path}"
      url = "https://doi.org/#{doi}"
      puts blue url
      `cd #{dir_path} && wget --user-agent "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:15.0) Gecko/20100101 Firefox/15.0.1" --tries=1 -O meta.html "#{url}"`
      meta=Nokogiri::HTML(open(html_file_path))
      a_property=meta.css('meta').map{|m| {m['property'] => m['content']}}
      a_name=meta.css('meta').map{|m| {m['name'] => m['content']}}
      h_property=a_property.reduce(Hash.new, :merge)
      h_name=a_name.reduce(Hash.new, :merge)
      self.toc_url = h_property['og:image']
      if toc_url.blank?
        puts cyan "ToC remains blank"
        redirect_input=meta.css("input[name=redirectURL]")
        url = URI.unescape(redirect_input[0].attributes["value"].value)
        puts blue url
        if url.include? "sciencedirect"
          self.toc_url = elsevier_retriever(url)[:toc_url]
        end
      end
      if crossref.present? && crossref['abstract'].blank?
        puts cyan "retrieve abstract"
        unless h_property['og:description'] == "Click or tap to learn more."
          self.crossref['abstract'] = h_property['og:description']
        else
          self.crossref['abstract'] = h_name['Description']
        end
      end

      if crossref.present? && crossref['title'].blank?
        puts cyan "retrieve title"
        if h_property['dc.title'].present?
          self.crossref['title'] = h_property['dc.title']
        elsif h_property['og:title'].present?
          self.crossref['title'] = h_property['og:title']
        elsif h_property['twitter:title'].present?
          self.crossref['title'] = h_property['twitter:title']
        end
      else
        puts cyan "do not retrieve title"
      end

      FileUtils.rm_rf(Dir[dir_path])
    rescue StandardError => e
      puts red e
    end
    return toc_url
  end
end

def elsevier_retriever(url)
  pn = Pathname(Time.now.strftime("%Y_%m_%d_%H_%M_%S"))
  dir_path = "public/tmp/html/#{pn.basename}"
  html_file_path = "#{dir_path}/meta.html"
  FileUtils.mkdir_p dir_path
  puts "html_file_path: #{html_file_path}"
  puts blue url
  begin
    `cd #{dir_path} && wget --user-agent "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:15.0) Gecko/20100101 Firefox/15.0.1" --tries=1 -O meta.html "#{url}"`
    meta=Nokogiri::HTML(open(html_file_path))
    a_property=meta.css('meta').map{|m| {m['property'] => m['content']}}
    a_name=meta.css('meta').map{|m| {m['name'] => m['content']}}
    h_property=a_property.reduce(Hash.new, :merge)
    h_name=a_name.reduce(Hash.new, :merge)
    toc_url = h_property['og:image']
    description = h_property['og:description']
    FileUtils.rm_rf(Dir[dir_path])
  rescue StandardError => e
    puts red e
  end

  return {toc_url: toc_url, description: description}
end

def framework_remarks(url="https://asia.iza-structure.org/IZA-SC/framework.php?STC=GIS")
  pn = Pathname(Time.now.strftime("%Y_%m_%d_%H_%M_%S"))
  dir_path = "public/tmp/html/#{pn.basename}"
  html_file_path = "#{dir_path}/meta.html"
  FileUtils.mkdir_p dir_path
  puts "html_file_path: #{html_file_path}"
  puts blue url
  `cd #{dir_path} && wget --user-agent "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:15.0) Gecko/20100101 Firefox/15.0.1" --tries=1 -O meta.html "#{url}"`
  meta=Nokogiri::HTML(open(html_file_path))
  table_content=meta.css('td').map{|m| m.content.gsub("\t","").gsub("\n", "").strip()}
  parameters_list=["Cell Parameters:", "Volume =","RDLS =","Framework density (FDSi):", "Topological density:", "Ring sizes (# T-atoms):", "Channel dimensionality:", "Maximum diameter of a sphere:","that can be included", "that can diffuse along","Accessible volume:", "Secondary Building Units:"]
  table_content.index("Cell Parameters:")
  index_list = parameters_list.map{|p| table_content.index(p)}
  index_hash = parameters_list.map{|p| {p => table_content.index(p)}}.reduce(Hash.new, :merge)



end



end
