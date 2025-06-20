# frozen_string_literal: true

require_relative 'base_exporter'

class DisciplinesExporter < BaseExporter
  def export(filename)
    disciplines_data = api.all_disciplines

    rows = disciplines_data.map do |discipline|
      [
        discipline[:disciplina_id],
        discipline[:nome]
      ]
    end

    headers = %w[legacy_id name]
    write_to_csv(filename, headers, rows)
  end
end
