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
  end

  def call
    puts 'Syncing...'
    beast_saber.each_song do |song|
      puts "#{song['song_key']} - #{song['hash']} - #{song['title']}"
    end
  end

private

  def beast_saber
    @beast_saber ||= BeastSaber.new(
      username: context.username
    )
  end
end
