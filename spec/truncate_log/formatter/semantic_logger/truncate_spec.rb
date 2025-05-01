# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'semantic_logger'

RSpec.describe TruncateLog::Formatter::SemanticLogger::Truncate do
  subject(:formatter) { described_class.new }

  describe '#call' do
    let(:log) do
      log = ::SemanticLogger::Log.new('TestLogger', :info)
      log.message = 'Test message'
      log.payload = payload
      log
    end

    let(:payload) { { test: 'data' } }
    let(:json_result) { '{"message":"Test message","payload":{"test":"data"}}' }

    before do
      allow(TruncateLog::Truncator).to receive(:truncate).and_call_original
      allow_any_instance_of(::SemanticLogger::Formatters::Json).to receive(:call).and_return(json_result)
    end

    it 'truncates the log output and returns valid JSON' do
      result = formatter.call(log, nil)

      expect(TruncateLog::Truncator).to have_received(:truncate).with(
        hash_including('message' => 'Test message', 'payload' => { 'test' => 'data' })
      )

      expect { JSON.parse(result) }.not_to raise_error
      parsed_result = JSON.parse(result)
      expect(parsed_result).to be_a(Hash)
      expect(parsed_result).to include('message', 'payload')
    end
  end
end
