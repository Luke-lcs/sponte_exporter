# frozen_string_literal: true

require_relative 'base_exporter'

class TeachersExporter < BaseExporter
  def export(filename)
    teachers_data = api.teachers

    rows = teachers_data.map do |teacher|
      [
        teacher[:funcionario_id],
        teacher[:nome],
        sanitize_email(teacher[:email]) # Usando método do helper
      ]
    end

    headers = %w[legacy_id name email]
    write_to_csv(filename, headers, rows)
  end
end
