# frozen_string_literal: true

require_relative 'client_operation'

class ApiClient
  include ClientOperation

  def initialize(token, client_code)
    @token = token
    @client_code = client_code
  end


  def classrooms
    @_classrooms ||= begin
                       puts 'Buscando turmas na API...'
                       response = soap_client.call(:get_turmas, soap_params(:get_turmas, @token, @client_code, classrooms_search_params))
                       process_response(response, :get_turmas_response, :get_turmas_result, :ws_turma)
                     end
  end

  def teachers
    @_teachers ||= begin
                     puts 'Buscando professores na API...'
                     response = soap_client.call(:get_funcionarios, soap_params(:get_funcionarios, @token, @client_code, teachers_search_params))
                     process_response(response, :get_funcionarios_response, :get_funcionarios_result, :ws_funcionario)
                   end
  end

  def timesheets
    @_timesheets ||= begin
                       puts 'Buscando quadros de horários na API...'
                       response = soap_client.call(:get_quadro_horarios, soap_params(:get_quadro_horarios, @token, @client_code, timesheets_search_params))
                       sheets = process_response(response, :get_quadro_horarios_response, :get_quadro_horarios_result, :ws_quadro_horarios)
                       sheets.uniq { |s| [s[:turma_id], s[:disciplina_id], s[:professor_id]] }
                     end
  end


  def all_disciplines
    @_all_disciplines ||= begin
                            puts 'Buscando disciplinas de todas as turmas...'
                            disciplines = classrooms.flat_map do |classroom|
                              enrollments = enrollments_for_classroom(classroom[:turma_id])
                              enrollments.flat_map { |enrollment| enrollment.dig(:disciplinas, :ws_disciplinas) }
                            end.compact

                            disciplines.uniq { |d| d[:disciplina_id] }
                          end
  end


  def all_students_and_responsibles
    @_all_students_and_responsibles ||= begin
                                          puts 'Buscando alunos e responsáveis de todas as turmas...'
                                          students = []
                                          responsibles = []

                                          classrooms.each do |classroom|
                                            enrollments_for_classroom(classroom[:turma_id]).each do |enrollment|
                                              student_id = enrollment[:aluno_id]
                                              students.concat(student_details(student_id))
                                              responsibles.concat(responsibles_for_student(student_id))
                                            end
                                          end

                                          { students: students.uniq { |s| s[:aluno_id] }, responsibles: responsibles.uniq { |r| r[:responsavel_id] } }
                                        end
  end

  def all_occurrences
    puts 'Buscando ocorrências de todos os alunos...'
    student_ids = classrooms.flat_map do |classroom|
      enrollments_for_classroom(classroom[:turma_id]).map { |enrollment| enrollment[:aluno_id] }
    end.uniq

    student_ids.flat_map { |student_id| occurrences_for_student(student_id) }
  end


  private


  def enrollments_for_classroom(classroom_id)
    response = soap_client.call(:get_matriculas, soap_params(:get_matriculas, @token, @client_code, students_search_params(classroom_id)))
    process_response(response, :get_matriculas_response, :get_matriculas_result, :ws_matricula)
  end

  def student_details(student_id)
    response = soap_client.call(:get_alunos, soap_params(:get_alunos, @token, @client_code, active_student_search_params(student_id)))
    process_response(response, :get_alunos_response, :get_alunos_result, :ws_aluno)
  end

  def responsibles_for_student(student_id)
    response = soap_client.call(:get_responsaveis, soap_params(:get_responsaveis, @token, @client_code, responsibles_search_params(student_id)))
    process_response(response, :get_responsaveis_response, :get_responsaveis_result, :ws_responsavel)
  end

  def occurrences_for_student(student_id)
    response = soap_client.call(:get_ocorrencias_aluno, soap_params(:get_ocorrencias_aluno, @token, @client_code, {}, student_id))
    process_response(response, :get_ocorrencias_aluno_response, :get_ocorrencias_aluno_result, :ws_ocorrencias)
  end


  def process_response(response, *path)
    data = response.body.dig(*path)
    return [] if data.nil?
    data.is_a?(Array) ? data : [data]
  end


  def teachers_search_params
    { 'sParametrosBusca' => 'Professor=1' }
  end

  def timesheets_search_params
    { 'sParametrosBusca' => 'Situacao=-1' }
  end

  def students_search_params(classroom_id)
    { 'sParametrosBusca' => "TurmaID=#{classroom_id}" }
  end

  def active_student_search_params(student_id)
    { 'sParametrosBusca' => "AlunoID=#{student_id}" }
  end

  def responsibles_search_params(student_id)
    { 'sParametrosBusca' => "AlunoID=#{student_id}" }
  end

  def classrooms_search_params
    { 'sParametrosBusca' => 'Situacao=-1' }
  end
end
