# frozen_string_literal: true

require 'beast_saber'
require 'beat_saber'
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
      'cygdrive',
      'f',
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
    # puts JSON.pretty_generate(context.data)
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
    end
  end

  def download!
    context.data.each do |hash, song|
      next if song[:downloaded]
      next unless song[:bookmarked]
      puts "download - #{song[:title]}"
    end
  end

  def prune!
    context.data.each do |hash, song|
      next unless song[:downloaded]
      next if song[:builtin]
      next if song[:bookmarked]
      puts "prune - #{song[:title]}"
    end
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
end
