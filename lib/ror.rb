module Ror
  include Colors
  require 'uri'
  require 'net/http'
  require 'openssl'
  require 'json'
  require 'http'


  def query_ror_by_term(term)
    response = HTTP.get("https://api.ror.org/organizations?query=#{URI.encode(term.gsub(';',',').strip)}")
    puts "https://api.ror.org/organizations?query=#{URI.encode(term.strip)}"
    response_hash = JSON.parse(response.to_s)
    result = response_hash.symbolize_keys
    unless result[:errors].present?
      items = result[:items]
      array = items.map{|n| [ n['name'], n['id'] , n['acronyms'][0] , n['country']['country_name'] , n['links'][0] ]}
    else
      array = result[:errors]
    end
    return array
  end

  def query_ror_by_affiliation(affiliation)
    #note affiliation should be an array of hashes [{name: "something"}, {name: "something else"}]
    puts cyan __method__
    result = nil
    index = 0
    loop do
       affi = affiliation_collector(affiliation, index)
       puts green affi
       response = HTTP.get("https://api.ror.org/organizations?affiliation=#{URI.encode(affi.gsub(';',',').strip)}")
       result = JSON.parse(response.to_s).symbolize_keys
       index += 1
       break if (index >= affiliation.length || result[:number_of_results] > 0)
    end

    if result[:number_of_results] == 0
      index = 0
      loop do
         affi = affiliation[index][:name]
         puts green affi
         response = HTTP.get("https://api.ror.org/organizations?affiliation=#{URI.encode(affi.gsub(';',',').strip)}")
         result = JSON.parse(response.to_s).symbolize_keys
         index += 1
         break if (index >= affiliation.length || result[:number_of_results] > 0)
      end
    end
    unless result[:errors].present? || result[:number_of_results] == 0
      best_match = result[:items].sort_by{ |hsh| -hsh['score']}.first['organization']
      array = best_match.values_at('name', 'id')
    else
      array = [affiliation.first[:name], nil]
    end
    return array
  end


  def affiliation_collector(affiliation, finish=0)
    result = ''
    finish = [finish, affiliation.size-1].min
    for i in 0..finish
      if finish == 0
        result +=  affiliation[i][:name]
      elsif i == finish
        result +=  affiliation[i][:name]
      elsif i != finish
        result +=  affiliation[i][:name] + ", "
      end
    end
    return result
  end

end
