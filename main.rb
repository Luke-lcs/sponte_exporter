# frozen_string_literal: true

require 'active_support/all'

require_relative 'lib/api/client'
require_relative 'lib/exporters/classrooms_exporter'
require_relative 'lib/exporters/disciplines_exporter'
require_relative 'lib/exporters/students_and_responsibles_exporter'
require_relative 'lib/exporters/teachers_exporter'
require_relative 'lib/exporters/timesheets_exporter'
require_relative 'lib/exporters/occurrences_exporter'


puts 'Qual o Token da Escola?'
TOKEN = gets.chomp # 'Token'

puts 'Qual o Código de Cliente da Escola?'
CLIENT_CODE = gets.chomp # 'Code'

puts 'Qual o nome da Escola? (Use para nomear os arquivos, sem espaços ou caracteres especiais)'
SCHOOL_NAME = gets.chomp # 'Name'

Dir.mkdir('exports') unless Dir.exist?('exports')

puts "\nIniciando exportação para a escola: #{SCHOOL_NAME}..."

api_client = ApiClient.new(TOKEN, CLIENT_CODE)


ClassroomsExporter.new(api_client).export("exports/#{SCHOOL_NAME}-classrooms.csv")
DisciplinesExporter.new(api_client).export("exports/#{SCHOOL_NAME}-disciplines.csv")
TeachersExporter.new(api_client).export("exports/#{SCHOOL_NAME}-teachers.csv")
StudentsAndResponsiblesExporter.new(api_client).export("exports/#{SCHOOL_NAME}-")

# TimesheetsExporter.new(api_client).export("exports/#{SCHOOL_NAME}-timesheets.csv")
# OccurrencesExporter.new(api_client).export("exports/#{SCHOOL_NAME}-occurrences.csv")

puts "\nProcesso de exportação concluído com sucesso!"
