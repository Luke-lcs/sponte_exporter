# frozen_string_literal: true

require_relative 'base_exporter'

class ClassroomsExporter < BaseExporter

  def export(filename)
    classrooms_data = api.classrooms

    rows = classrooms_data.map do |classroom|
      [
        classroom[:turma_id],
        "#{classroom[:nome]} - #{classroom[:ano_letivo]}"
      ]
    end

    headers = %w[legacy_id name]
    write_to_csv(filename, headers, rows)
  end
end
