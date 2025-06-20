# frozen_string_literal: true

require "active_support/core_ext/string/filters"

module Sanitizer
  def sanitize_email(value)
    value.blank? ? nil : value
  end

  def sanitize_name(value)
    value.blank? ? nil : value
  end
end
