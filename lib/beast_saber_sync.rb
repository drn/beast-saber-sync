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
    context.path ||= '/cygdrive/f/Program Files (x86)/Steam/steamapps/common/Beat Saber'
    context.data = {}
  end

  def call
    puts 'Syncing...'
    load_bookmarks!
    load_downloaded!
    # download!
    # prune!
    puts JSON.pretty_generate(context.data)
  end

private

  def load_bookmarks!
    beast_saber.each_song do |song|
      key = song['song_key']
      hash = song['hash']
      title = song['title']

      context.data[key] ||= {}
      context.data[key][:bookmarked] = true
      context.data[key][:title] = title
      context.data[key][:hash] = hash
    end
  end

  def load_downloaded!
    beat_saber.songs.each do |song|

    end
  end

  def beast_saber
    @beast_saber ||= BeastSaber.new(
      username: context.username
    )
  end

  def beat_saber
    @beat_saber ||= BeatSaber.new
  end
end
