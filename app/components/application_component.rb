# frozen_string_literal: true

# Base class for all ViewComponents in the application.
# All components should inherit from this class to share common functionality.
#
# @example Creating a new component
#   class MyComponent < ApplicationComponent
#     def initialize(title:)
#       @title = title
#     end
#   end
#
class ApplicationComponent < ViewComponent::Base
  # Include helpers that should be available in all components
  include ApplicationHelper

  # Enable sidecar templates (component.html.erb in same directory as component.rb)
  # This is the default in ViewComponent, but we explicitly set it for clarity

  private

  # Helper method to generate unique DOM IDs for components
  # Useful for accessibility and JavaScript targeting
  #
  # @param suffix [String, nil] Optional suffix to append to the ID
  # @return [String] A unique DOM ID
  def component_id(suffix = nil)
    base_id = "#{self.class.name.underscore.dasherize}-#{object_id}"
    suffix ? "#{base_id}-#{suffix}" : base_id
  end

  # Helper method to merge CSS classes with defaults
  # Useful for components that accept custom classes
  #
  # @param default_classes [String] Default CSS classes
  # @param custom_classes [String, nil] Custom CSS classes to add
  # @return [String] Merged CSS classes
  def merge_classes(default_classes, custom_classes = nil)
    [default_classes, custom_classes].compact.join(" ")
  end
end
