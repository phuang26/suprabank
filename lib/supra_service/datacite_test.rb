require 'uri'
require 'net/http'
require 'openssl'
require 'json'

url = URI("https://api.datacite.org/dois")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Post.new(url)
request["content-type"] = 'application/vnd.api+json'
request["authorization"] = 'Basic VElCLlNVUFJBQkFOSzojXDl8S3AzODNFTDs2NQ=='


hs={data:
      {attributes:
        {doi:"10.34804/supra2020092"}
      }
    }

request.body = hs.to_json

response = http.request(request)
puts response.read_body
