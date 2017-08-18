require "json"
require "http"
require "optparse"
require "pp"
require "net/http"
require "rubygems"

# Place holders for Yelp Fusion's OAuth 2.0 credentials. Grab them
# from https://www.yelp.com/developers/v3/manage_app
CLIENT_ID = "x0LOXFAjrgc9FObJNnszTQ"
CLIENT_SECRET = "1mWDj5IL7JIGZ7KLnvzTNpWDy2777z3NHr4XvBf54MPLDRJGu3gJqxQG8J1gXPbR"


# Constants, do not change these
API_HOST = "https://api.yelp.com"
SEARCH_PATH = "/v3/businesses/search"
BUSINESS_PATH = "/v3/businesses/"  # trailing / because we append the business id to the path
TOKEN_PATH = "/oauth2/token"
GRANT_TYPE = "client_credentials"


DEFAULT_BUSINESS_ID = "yelp-san-francisco"
DEFAULT_TERM = "dinner"
DEFAULT_LOCATION = "San Francisco, CA"
SEARCH_LIMIT = 5


# Make a request to the Fusion API token endpoint to get the access token.
# 
# host - the API's host
# path - the oauth2 token path
#
# Examples
#
#   bearer_token
#   # => "Bearer some_fake_access_token"
#
# Returns your access token
def bearer_token
  # Put the url together
  url = "#{API_HOST}#{TOKEN_PATH}"

  raise "Please set your CLIENT_ID" if CLIENT_ID.nil?
  raise "Please set your CLIENT_SECRET" if CLIENT_SECRET.nil?

  # Build our params hash
  params = {
    client_id: CLIENT_ID,
    client_secret: CLIENT_SECRET,
    grant_type: GRANT_TYPE
  }

  response = HTTP.post(url, params: params)
  parsed = response.parse

  "#{parsed['token_type']} #{parsed['access_token']}"
end


# Make a request to the Fusion search endpoint. Full documentation is online at:
# https://www.yelp.com/developers/documentation/v3/business_search
#
# term - search term used to find businesses
# location - what geographic location the search should happen
#
# Examples
#
#   search("burrito", "san francisco")
#   # => {
#          "total": 1000000,
#          "businesses": [
#            "name": "El Farolito"
#            ...
#          ]
#        }
#
#   search("sea food", "Seattle")
#   # => {
#          "total": 1432,
#          "businesses": [
#            "name": "Taylor Shellfish Farms"
#            ...
#          ]
#        }
#
# Returns a parsed json object of the request
def search(term, location)
  url = "#{API_HOST}#{SEARCH_PATH}"
  term.split(" ")
  params = {
    term: term,
    location: location,
    limit: SEARCH_LIMIT
  }

  response = HTTP.auth(bearer_token).get(url, params: params)
  response.parse["businesses"]
end 

def news(search)
   endpoint="https://api.nytimes.com/svc/search/v2/articlesearch.json"
   uri = URI(endpoint)
   http = Net::HTTP.new(uri.host, uri.port)
   http.use_ssl = true
   uri.query = URI.encode_www_form({
     "api-key" => "5dd3699640be47a7bca391c293ad2bde",
     "q" => search
   })
   request = Net::HTTP::Get.new(uri.request_uri)
   result = JSON.parse(http.request(request).body)
   puts result
   return result
end

def weather(search)
    endpoint="https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22nome%2C%20ak%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
    sample_uri = URI(endpoint) #opens a portal to the data at that link
    sample_response = Net::HTTP.get(sample_uri) #go grab the data in the portal
    sample_parsedResponse = JSON.parse(sample_response) #makes data easy to read
    puts sample_parsedResponse
    return sample_parsedResponse["query"]["results"]["channel"]["item"]["forecast"]
end

