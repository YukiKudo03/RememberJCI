# frozen_string_literal: true

# ButtonComponent provides a flexible button/link element with various variants and sizes.
#
# @example Basic usage
#   <%= render ButtonComponent.new(variant: :primary) { "Click me" } %>
#
# @example As a link
#   <%= render ButtonComponent.new(href: "/path") { "Go to page" } %>
#
# @example Full width with danger variant
#   <%= render ButtonComponent.new(variant: :danger, full_width: true) { "Delete" } %>
#
class ButtonComponent < ApplicationComponent
  VARIANTS = {
    primary: "bg-blue-600 hover:bg-blue-700 text-white border-transparent",
    secondary: "bg-gray-200 hover:bg-gray-300 text-gray-900 border-transparent",
    danger: "bg-red-600 hover:bg-red-700 text-white border-transparent",
    ghost: "bg-transparent hover:bg-gray-100 text-gray-700 border-gray-300"
  }.freeze

  SIZES = {
    sm: "px-3 py-1.5 text-sm",
    md: "px-4 py-2 text-base",
    lg: "px-6 py-3 text-lg"
  }.freeze

  BASE_CLASSES = "inline-flex items-center justify-center font-medium rounded-md border " \
                 "focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 " \
                 "transition-colors duration-200"

  DISABLED_CLASSES = "opacity-50 cursor-not-allowed"

  # @param variant [Symbol] Button style variant (:primary, :secondary, :danger, :ghost)
  # @param size [Symbol] Button size (:sm, :md, :lg)
  # @param disabled [Boolean] Whether the button is disabled
  # @param full_width [Boolean] Whether the button should take full width
  # @param href [String, nil] If provided, renders as an anchor tag instead of button
  # @param html_options [Hash] Additional HTML attributes to pass to the element
  def initialize(variant: :primary, size: :md, disabled: false, full_width: false, href: nil, **html_options)
    @variant = variant
    @size = size
    @disabled = disabled
    @full_width = full_width
    @href = href
    @html_options = html_options
  end

  # @return [Boolean] true if this should render as a link
  def link?
    @href.present?
  end

  # @return [String] The tag name to use for rendering
  def tag_name
    link? ? :a : :button
  end

  # @return [Hash] HTML attributes for the element
  def html_attributes
    attrs = @html_options.merge(class: css_classes)

    if link?
      attrs[:href] = @href
    else
      attrs[:type] ||= "button"
      attrs[:disabled] = true if @disabled
    end

    attrs
  end

  private

  # @return [String] Combined CSS classes for the button
  def css_classes
    classes = [
      BASE_CLASSES,
      variant_classes,
      size_classes
    ]

    classes << DISABLED_CLASSES if @disabled
    classes << "w-full" if @full_width
    classes << @html_options[:class] if @html_options[:class]

    classes.compact.join(" ")
  end

  # @return [String] CSS classes for the current variant
  def variant_classes
    VARIANTS.fetch(@variant) do
      raise ArgumentError, "Invalid variant: #{@variant}. Valid variants: #{VARIANTS.keys.join(', ')}"
    end
  end

  # @return [String] CSS classes for the current size
  def size_classes
    SIZES.fetch(@size) do
      raise ArgumentError, "Invalid size: #{@size}. Valid sizes: #{SIZES.keys.join(', ')}"
    end
  end
end
