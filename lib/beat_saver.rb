# frozen_string_literal: true

require 'pry'
require 'faraday'
require 'faraday_middleware'
require 'zip'
require 'fileutils'

class BeatSaver
  def initialize(path:)
    @path = path
  end

  def download!(hash)
    # download metadata
    response = client.get("api/maps/hash/#{hash}")
    unless response.success?
      puts "Failed to query #{hash}"
      return
    end

    # download song
    latest_version = response.body['versions'][0]
    download_url = latest_version['downloadURL']
    download = client.get(download_url)
    unless download.success?
      puts "Failed to download #{hash}"
      return
    end

    # folder name
    key = response.body['id']
    name = response.body['name']
    author = response.body['uploader']['name']
    folder = +"#{key} (#{name} - #{author})"
    folder.gsub!('/', ' ') # ensure filename excludes conflicting /s

    destination = @path + '/Beat Saber_Data/CustomLevels/' + folder

    # create directory
    FileUtils.rm_rf(destination) if File.directory?(destination)
    Dir.mkdir(destination)

    temp = Tempfile.new(hash)
    temp.write(download.body)

    Zip::File.open(temp.path) do |zipfile|
      zipfile.each do |entry|
        entry.extract(destination + '/' + entry.name)
      end
    end

    metadata = { hash: hash, scannedTime: Time.now.to_i*1_000 }
    File.write(destination + '/metadata.dat', metadata.to_json)
  ensure
    temp&.close
    temp&.unlink
  end

private

  def client
    @client ||= Faraday.new(
      url: 'https://beatsaver.com/'
    ) do |faraday|
      faraday.request  :json
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter  :net_http
    end
  end
end
