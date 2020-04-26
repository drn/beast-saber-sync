# frozen_string_literal: true

require 'beast_saber'
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
    context.data = {}
  end

  def call
    puts 'Syncing...'
    load_bookmarks!
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

  def beast_saber
    @beast_saber ||= BeastSaber.new(
      username: context.username
    )
  end
end
