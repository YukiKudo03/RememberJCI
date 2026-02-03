# frozen_string_literal: true

module FileUploadHelpers
  def fixture_file_upload_from_content(content, filename, content_type)
    tempfile = Tempfile.new([ File.basename(filename, ".*"), File.extname(filename) ])
    tempfile.write(content)
    tempfile.rewind

    Rack::Test::UploadedFile.new(tempfile.path, content_type, true, original_filename: filename)
  end
end

RSpec.configure do |config|
  config.include FileUploadHelpers
end
