# frozen_string_literal: true

require 'pry'

class BeatSaber
  def initialize(path:)
    @path = path
  end

  def songs
    puts files
    []
  end

private

  def files
    Dir.entries(@path + '/Beat Saber_Data/CustomLevels')
  end
end
