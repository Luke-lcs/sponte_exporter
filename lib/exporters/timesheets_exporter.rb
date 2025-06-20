# frozen_string_literal: true

require_relative 'base_exporter'

class TimesheetsExporter < BaseExporter
  def export(filename)
    timesheets_data = api.timesheets

    rows = timesheets_data.map do |timesheet|
      [
        timesheet[:turma_id],
        timesheet[:turma],
        timesheet[:disciplina_id],
        timesheet[:disciplina],
        timesheet[:professor_id],
        timesheet[:professor]
      ]
    end

    headers = %w[turma_id turma_name disciplina_id disciplina_name professor_id professor_name]
    write_to_csv(filename, headers, rows)
  end
end
