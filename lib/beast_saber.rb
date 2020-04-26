# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

# BeastSaber API client
class BeastSaber
  def initialize(username:)
    @username = username
  end

  def each_song
    params = { bookmarked_by: @username }
    loop do
      response = client.get('songs', params)
      response.body['songs'].each do |song|
        yield(song)
      end
      break if response.body['next_page'].nil?
      params[:page] = response.body['next_page']
    end
  end

private

  def client
    @client ||= Faraday.new(
      url: 'https://bsaber.com/wp-json/bsaber-api/'
    ) do |faraday|
      faraday.request  :json
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter  :net_http
    end
  end
end
