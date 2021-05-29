# frozen_string_literal: true

require 'beast_saber'
require 'beat_saber'
require 'beat_saver'
require 'interactor'

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
    context.path ||= [
      '/cygdrive',
      'j',
      'Program Files (x86)',
      'Steam',
      'steamapps',
      'common',
      'Beat Saber'
    ].join('/')
    context.data = {}
  end

  def call
    puts 'Syncing...'
    load_bookmarks!
    load_downloaded!
    download!
    prune!
    update_playlist!
    total = context.data.count{ |_, song| song[:bookmarked] }
    puts "Loaded #{total} custom songs"
  end

private

  def load_bookmarks!
    beast_saber.each_song do |song|
      hash = song['hash']
      context.data[hash] ||= {}
      context.data[hash][:bookmarked] = true
      context.data[hash][:key] = song['song_key']
      context.data[hash][:title] = song['title']
      context.data[hash][:author] = song['level_author_name']
    end
  end

  def load_downloaded!
    beat_saber.songs.each do |song|
      hash = song[:hash]
      context.data[hash] ||= {}
      context.data[hash][:downloaded] = true
      context.data[hash][:builtin] = song[:builtin]
      context.data[hash][:key] ||= song[:key]
      context.data[hash][:title] ||= song[:title]
      context.data[hash][:author] ||= song[:author]
      context.data[hash][:filename] ||= song[:filename]
    end
  end

  def download!
    context.data.each do |hash, song|
      next if song[:downloaded]
      next unless song[:bookmarked]
      puts "Downloading #{song[:title]}"
      beat_saver.download!(hash)
    end
  end

  def prune!
    context.data.each do |hash, song|
      next unless song[:downloaded]
      next if song[:builtin]
      next if song[:bookmarked]
      next unless song[:filename]
      puts "Pruning #{song[:title]}"

      destination =  [
        context.path,
        '/Beat Saber_Data/CustomLevels/',
        song[:filename]
      ].join
      FileUtils.rm_rf(destination) if File.directory?(destination)
    end
  end

  def update_playlist!
    destination = [
      context.path,
      '/Playlists/',
      'BeastSaberBookmarks.json'
    ].join
    FileUtils.rm(destination) if File.directory?(destination)

    playlist = {
      playlistTitle:  'BeastSaber Playlist',
      playlistAuthor: context.username,
      image:          '1',
      songs:          context.data.map do |hash, song|
        next unless song[:bookmarked]
        {
          key:      song[:key],
          hash:     hash,
          songName: song[:title]
        }
      end.compact
    }
    File.write(destination, JSON.pretty_generate(playlist))
  end

  def beast_saber
    @beast_saber ||= BeastSaber.new(
      username: context.username
    )
  end

  def beat_saber
    @beat_saber ||= BeatSaber.new(
      path: context.path
    )
  end

  def beat_saver
    @beat_saver ||= BeatSaver.new(
      path: context.path
    )
  end
end
