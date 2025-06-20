# frozen_string_literal: true

require 'savon'
require_relative 'request_body_builder'

module ClientOperation
  HOST = 'https://api.sponteeducacional.net.br'
  XML_NAMESPACE = 'http://api.sponteeducacional.net.br/'.freeze
  WSDL_URL = "#{HOST}/WSAPIEdu.asmx?wsdl".freeze

  SOAP_CLIENT = Savon.client(wsdl: WSDL_URL) do
    soap_version 2
    namespace_identifier nil
    env_namespace :soap12
    log false
  end

  def soap_client
    SOAP_CLIENT
  end

  def soap_params(action_name, token, client_code, attributes, student_id = nil)
    {
      xml: RequestBodyBuilder.new(
        action_name,
        attributes,
        token: token,
        client_code: client_code,
        student_id: student_id
      ).build,
      soap_action: "#{XML_NAMESPACE}#{action_name.to_s.camelize}"
    }
  end
end
