# frozen_string_literal: true

# ModalComponent provides a flexible modal dialog with various sizes and slot support.
#
# @example Basic usage
#   <%= render ModalComponent.new(title: "Confirm") do |modal| %>
#     <% modal.with_body do %>
#       Are you sure you want to continue?
#     <% end %>
#     <% modal.with_footer do %>
#       <%= render ButtonComponent.new(variant: :primary) { "Yes" } %>
#       <%= render ButtonComponent.new(variant: :secondary) { "No" } %>
#     <% end %>
#   <% end %>
#
# @example Different sizes
#   <%= render ModalComponent.new(size: :lg, title: "Large Modal") do |modal| %>
#     <% modal.with_body { "Large content area" } %>
#   <% end %>
#
# @example Without close button
#   <%= render ModalComponent.new(closeable: false) do |modal| %>
#     <% modal.with_body { "Cannot be closed by X button" } %>
#   <% end %>
#
class ModalComponent < ApplicationComponent
  SIZES = {
    sm: "max-w-sm",
    md: "max-w-md",
    lg: "max-w-lg",
    xl: "max-w-xl"
  }.freeze

  BASE_CLASSES = "fixed inset-0 z-50 flex items-center justify-center"
  BACKDROP_CLASSES = "fixed inset-0 bg-black bg-opacity-50 transition-opacity"
  DIALOG_BASE_CLASSES = "relative bg-white rounded-lg shadow-xl w-full mx-4 " \
                        "transform transition-all"
  HEADER_CLASSES = "flex items-center justify-between px-6 py-4 border-b border-gray-200"
  BODY_CLASSES = "px-6 py-4"
  FOOTER_CLASSES = "flex items-center justify-end gap-3 px-6 py-4 border-t border-gray-200"
  CLOSE_BUTTON_CLASSES = "absolute top-4 right-4 text-gray-400 hover:text-gray-600 " \
                         "focus:outline-none focus:ring-2 focus:ring-blue-500 rounded"
  TITLE_CLASSES = "text-lg font-semibold text-gray-900"

  renders_one :header
  renders_one :body
  renders_one :footer

  # @param title [String, nil] Optional modal title
  # @param size [Symbol] Modal size (:sm, :md, :lg, :xl)
  # @param closeable [Boolean] Whether to show close button
  # @param close_on_backdrop [Boolean] Whether clicking backdrop closes modal
  # @param html_options [Hash] Additional HTML attributes
  def initialize(title: nil, size: :md, closeable: true, close_on_backdrop: true, **html_options)
    @title = title
    @size = size
    @closeable = closeable
    @close_on_backdrop = close_on_backdrop
    @html_options = html_options
  end

  # @return [String] Unique ID for the modal title element
  def title_id
    @title_id ||= component_id("title")
  end

  # @return [Boolean] Whether the modal has a title
  def title?
    @title.present?
  end

  # @return [Boolean] Whether the modal is closeable
  def closeable?
    @closeable
  end

  # @return [Boolean] Whether clicking backdrop closes modal
  def close_on_backdrop?
    @close_on_backdrop
  end

  # @return [String] The modal title
  def title
    @title
  end

  # @return [Hash] HTML attributes for the modal container
  def html_attributes
    base_attrs = {
      class: container_classes,
      data: stimulus_data,
      role: "dialog",
      "aria-modal": "true"
    }

    base_attrs["aria-labelledby"] = title_id if title?

    # Merge with user-provided attributes
    merge_html_attributes(base_attrs, @html_options)
  end

  # @return [String] CSS classes for the dialog element
  def dialog_classes
    [DIALOG_BASE_CLASSES, size_classes].join(" ")
  end

  # @return [String] CSS classes for the backdrop
  def backdrop_classes
    BACKDROP_CLASSES
  end

  # @return [String] CSS classes for the header section
  def header_classes
    HEADER_CLASSES
  end

  # @return [String] CSS classes for the body section
  def body_classes
    BODY_CLASSES
  end

  # @return [String] CSS classes for the footer section
  def footer_classes
    FOOTER_CLASSES
  end

  # @return [String] CSS classes for the close button
  def close_button_classes
    CLOSE_BUTTON_CLASSES
  end

  # @return [String] CSS classes for the title
  def title_classes
    TITLE_CLASSES
  end

  private

  # @return [String] Combined CSS classes for the container
  def container_classes
    classes = [BASE_CLASSES]
    classes << @html_options[:class] if @html_options[:class]
    classes.join(" ")
  end

  # @return [String] CSS classes for the current size
  def size_classes
    SIZES.fetch(@size) do
      raise ArgumentError, "Invalid size: #{@size}. Valid sizes: #{SIZES.keys.join(', ')}"
    end
  end

  # @return [Hash] Stimulus controller data attributes
  def stimulus_data
    data = {
      controller: "modal"
    }

    actions = ["keydown.esc->modal#closeOnEsc"]
    actions << "click->modal#closeOnBackdrop" if close_on_backdrop?

    data[:action] = actions.join(" ")
    data
  end

  # Merges user-provided HTML attributes with base attributes
  # @param base [Hash] Base attributes
  # @param custom [Hash] Custom attributes from user
  # @return [Hash] Merged attributes
  def merge_html_attributes(base, custom)
    result = base.dup

    custom.each do |key, value|
      if key == :class
        # Already handled in container_classes
        next
      elsif key == :data
        result[:data] = (result[:data] || {}).merge(value)
      else
        result[key] = value
      end
    end

    result
  end
end
