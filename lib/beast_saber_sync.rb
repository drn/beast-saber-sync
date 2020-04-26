# frozen_string_literal: true

require 'interactor'
require 'faraday'
require 'faraday_middleware'

# Primary entry-point into syncing logic.
# * fetches songs from specified BeastSaber user's bookmarks
# * fetches songs already installed
# * performs diff of songs by hash
# * for songs already installed - skip
# * for songs not yet installed - install
# * for songs no longer bookmarked - remove
class BeastSaberSync
  include Interactor

  before do
    context.username ||= 'sanguinerane'
  end

  def call
    puts 'Syncing...'
    songs
  end

private

  def songs
    response = client.get('songs', bookmarked_by: context.username)
    response.body['songs'].each do |song|
      puts "#{song['song_key']} - #{song['hash']} - #{song['title']}"
    end
  end

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
