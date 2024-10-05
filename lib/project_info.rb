require 'http'
require 'yaml'

config = YAML.safe_load(File.read('config/secrets.yml'))

def text_search(config, text)
  url = 'https://places.googleapis.com/v1/places:searchText'
  HTTP.headers(
    'X-Goog-Api-Key' => config['GOOGLE_KEY'],
    'X-Goog-FieldMask' => 'places.displayName,places.formattedAddress,places.id'
    ).post(url, json: {textQuery: text})
end

def place_detail(config, id)
  url = "https://places.googleapis.com/v1/places/#{id}"
  HTTP.headers(
    'X-Goog-Api-Key' => config['GOOGLE_KEY'],
    'X-Goog-FieldMask' => 'id,displayName,reviews,rating'
    ).get(url)
end

responses = {}
results = {}

responses['NTHU'] = text_search(config, '國立清華大學')
nthu = responses['NTHU'].parse
nthu_id = nthu['places'][0]['id']
results['id'] = nthu_id

responses['NTHU_Detail'] = place_detail(config, nthu_id)
nthu_detail = responses['NTHU_Detail'].parse
results['rating'] = nthu_detail['rating']
results['review'] = nthu_detail['reviews']

File.write('spec/fixtures/google_map_results.yml', results.to_yaml)