# frozen_string_literal: true

require "view_component/test_helpers"
require "capybara/rspec"

RSpec.configure do |config|
  # Include ViewComponent test helpers for component specs
  config.include ViewComponent::TestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component

  # Automatically infer spec type for files in spec/components/
  config.define_derived_metadata(file_path: %r{/spec/components/}) do |metadata|
    metadata[:type] = :component
  end
end
