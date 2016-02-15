require 'csv'
require 'json'
require 'set'

require 'faraday'
require 'sinatra'
require 'sinatra/cross_origin'
require 'sinatra/multi_route'

module WhosGotDirt
  class Proxy < Sinatra::Base
    register Sinatra::CrossOrigin
    register Sinatra::MultiRoute
    enable :cross_origin

    # Same order as in JSON Schema in whos_got_dirt-gem.
    # @see https://github.com/influencemapping/whos_got_dirt-gem/blob/master/schemas/schema.json
    PRIORITY_HEADERS = %w(
      @type
      type
      name
      description
      classification
      birth_date
      death_date
      founding_date
      dissolution_date
      parent_id
      other_names
      identifiers
      contact_details
      links
      sources
      created_at
      updated_at
    ).freeze

    helpers do
      # Returns a flattened hash in which the keys are JSON Pointer paths
      # (excluding the initial "/").
      #
      # @param value a value
      # @param [Array<String>] path the path components
      # @param [Hash] hash the flattened hash
      # @return [Hash] the flattened hash
      def flatten(value, path = [], hash = {})
        case value
        when Hash
          value.each do |k,v|
            flatten(v, path + [k], hash)
          end
        when Array
          value.each_with_index do |v,i|
            flatten(v, path + [i.to_s], hash)
          end
        else
          hash[path.join('/')] = value
        end
        hash
      end

      def header_index(header)
        PRIORITY_HEADERS.index(header.split('/', 2)[0])
      end
    end

    route :get, :post, '/entities.csv' do
      if request.request_method == 'GET'
        method = :get
      else
        method = :post
      end

      response = Faraday.send(method, "#{ENV['WHOS_GOT_DIRT_API_URL']}/entities", params)

      if response.success?
        data = JSON.load(response.body)
        if data['q0'] && data['q0']['result']
          headers = Set.new
          hashes = []

          data['q0']['result'].each do |result|
            hash = flatten(result)

            headers.merge(hash.keys)
            hashes << hash
          end

          headers = headers.to_a.sort do |a,b|
            c = header_index(a)
            d = header_index(b)
            if c && d
              c <=> d
            elsif c
              -1
            elsif d
              1
            else
              a <=> b
            end
          end

          body = CSV.generate do |csv|
            csv << headers
            hashes.each do |hash|
              row = []
              headers.each_with_index do |header,i|
                row[i] = hash[header]
              end
              csv << row
            end
          end
        else
          body = ''
        end

        content_type 'text/csv'
        body
      else
        content_type response.headers['content-type']
        [response.status, response.body]
      end
    end
  end
end
