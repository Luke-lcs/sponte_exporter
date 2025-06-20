# frozen_string_literal: true

require_relative 'base_exporter'

class OccurrencesExporter < BaseExporter
  def export(filename)
    occurrences_data = api.all_occurrences

    rows = occurrences_data.map do |item|
      next if item[:aluno_id] == '0' # Pula registros inválidos
      [
        item[:aluno_id],
        item[:aluno],
        item[:ocorrencia_id],
        item[:usuario],
        item[:funcionario],
        item[:turma],
        item[:descricao_tipo_ocorrencia],
        item[:descricao],
        item[:data_nascimento],
        item[:data],
        item[:periodo]
      ]
    end.compact

    headers = %w[aluno_id aluno ocorrencia_id usuario funcionario turma descricao_tipo_ocorrencia descricao data_nascimento data periodo]
    write_to_csv(filename, headers, rows)
  end
end
