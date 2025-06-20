# frozen_string_literal: true

require "active_support/core_ext/string/inflections"
require "active_support/core_ext/object/blank"
require 'nokogiri'

class RequestBodyBuilder
  XML_NAMESPACE = 'http://api.sponteeducacional.net.br/'

  ENVELOPE_ATTRIBUTES = {
    'xmlns:xsi': 'http://www.starstandards.org/webservices/2005/10/transport/operations/ProcessMessage',
    'xmlns:xsd': 'http://www.w3.org/2001/XMLSchema',
    'xmlns:soap12': 'http://www.w3.org/2003/05/soap-envelope'
  }.freeze

  def initialize(action_name, attributes, token:, client_code:, student_id: nil)
    @action_name = action_name
    @attributes  = attributes
    @token       = token
    @client_code = client_code
    @student_id  = student_id
  end

  def build
    Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      envelope(xml) do
        body(xml) do
          action(xml) do
            xml.sToken @token
            xml.nCodigoCliente @client_code
            xml.nAlunoID @student_id if @student_id.present?

            add_attributes_tags(xml, @attributes)
          end
        end
      end
    end.to_xml
  end

  private

  def envelope(xml)
    xml.send(:'soap12:Envelope', ENVELOPE_ATTRIBUTES) { yield }
  end

  def body(xml)
    xml.send(:'soap12:Body') { yield }
  end

  def action(xml)
    camelized_action_name = @action_name.to_s.camelize
    xml.send(camelized_action_name, xmlns: XML_NAMESPACE) { yield }
  end

  def add_attributes_tags(xml, attributes)
    attributes.each do |key, value|
      xml.send(key, value)
    end
  end
end
