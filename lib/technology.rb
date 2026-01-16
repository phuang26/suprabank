module Technology

 #define common methods for all techniques models

def generate_query_from_params(params)
  params = params.symbolize_keys
  query = ""
  position = 0
  params.each do |k,v|
    position += 1
    query += k.to_s
    if v.blank?
      query += " IS NULL"
    else
      if (k == :instrument || k == :nucleus)
        query += "='"
        query += "#{v}'"
      else
        query += "=#{v}"
      end
    end
    unless position == params.length
      query += " AND "
    end
  end
  return query
end




end
