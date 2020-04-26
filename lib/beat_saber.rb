# frozen_string_literal: true

require 'pry'

class BeatSaber
  def songs
    puts files
    []
  end

private

  def files
    Dir.entries(
      '/cygdrive/f/Program Files (x86)/Steam/steamapps/common/Beat Saber/Beat Saber_Data/CustomLevels'
    )
  end
end
