# frozen_string_literal: true

require_relative 'base_exporter'

class StudentsAndResponsiblesExporter < BaseExporter
  def export(filename_prefix)
    data = api.all_students_and_responsibles

    export_students(data[:students], "#{filename_prefix}students.csv")
    export_responsibles(data[:responsibles], "#{filename_prefix}responsibles.csv")
  end

  private

  def export_students(students_data, filename)
    rows = students_data.map do |student|
      [
        student[:aluno_id],
        student[:nome],
        student[:data_nascimento],
        sanitize_email(student[:email])
      ]
    end

    headers = %w[legacy_id name date_of_birth email]
    write_to_csv(filename, headers, rows)
  end

  def export_responsibles(responsibles_data, filename)
    rows = responsibles_data.map do |responsible|
      [
        responsible[:responsavel_id],
        responsible[:nome],
        responsible.dig(:alunos, :ws_alunos, :aluno_id),
        sanitize_email(responsible[:email]),
        kinship(responsible),
        responsible[:data_nascimento],
        responsible[:cpf_cnpj],
        responsible[:rg],
        responsible[:telefone],
        responsible[:celular],
        responsible[:cep],
        responsible[:endereco],
        responsible[:numero_endereco],
        responsible[:bairro],
        responsible[:cidade]
      ]
    end

    headers = %w[legacy_id name student_id email kinship date_of_birth cpf rg
                 telefone celular cep endereco numero bairro cidade]
    write_to_csv(filename, headers, rows)
  end

  def responsible_students(responsible)
    profiles = responsible.dig(:alunos, :ws_alunos)
    profiles.is_a?(Array) ? profiles : [profiles].compact
  end

  def kinship(responsible)
    students = responsible_students(responsible)
    return nil if students.empty?

    students.map { |s| s[:parentesco] }.first
  end
end
