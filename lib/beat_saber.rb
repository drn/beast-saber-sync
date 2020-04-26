# frozen_string_literal: true

class BeatSaber
  PARSE_REGEX = /^([^>]*?) \(([^>]*) - ([^>]*)\)$/.freeze

  def initialize(path:)
    @path = path
  end

  def songs
    filenames.map do |filename|
      filepath = [
        @path,
        'Beat Saber_Data',
        'CustomLevels',
        filename,
        'metadata.dat'
      ].join('/')
      next unless File.exists?(filepath)
      data = JSON.parse(File.read(filepath))
      data.merge(parse_path(filename)).transform_keys(&:to_sym)
    end.compact
  end

private

  def parse_path(filename)
    _, key, title, author = filename.match(PARSE_REGEX).to_a
    {
      key:      key,
      title:    title || filename,
      author:   author,
      filename: filename,
      builtin:  filename.include?('Built in')
    }
  end

  def filenames
    Dir.children(@path + '/Beat Saber_Data/CustomLevels')
  end
end
