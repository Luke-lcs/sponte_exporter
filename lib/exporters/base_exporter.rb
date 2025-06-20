# frozen_string_literal: true

require 'csv'
require_relative '../helpers/sanitizer'

class BaseExporter
  include Sanitizer

  attr_reader :api

  def initialize(api_client)
    @api = api_client
  end

  def export(_filename)
    raise NotImplementedError, "#{self.class} não implementou o método 'export'"
  end

  private

  def write_to_csv(filename, headers, data)
    puts "--> Exportando dados para #{filename}..."
    CSV.open(filename, 'w', write_headers: true, headers: headers) do |csv|
      data.each do |row|
        csv << row
      end
    end
    puts "    Concluído: #{data.size} linhas exportadas."
  rescue StandardError => e
    puts "    ERRO ao exportar para #{filename}: #{e.message}"
  end
end
