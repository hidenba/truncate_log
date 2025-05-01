# frozen_string_literal: true

require 'spec_helper'
require 'logger'

RSpec.describe TruncateLog::Formatter::TruncateFormatter do
  let(:original_formatter) { Logger::Formatter.new }
  let(:formatter) { described_class.new(original_formatter) }
  let(:severity) { 'INFO' }
  let(:time) { Time.now }
  let(:progname) { 'test_program' }

  describe '#initialize' do
    context 'when original_formatter is provided' do
      it 'uses the provided formatter' do
        custom_formatter = Logger::Formatter.new
        custom_truncate_formatter = described_class.new(custom_formatter)
        expect(custom_truncate_formatter.original_formatter).to eq(custom_formatter)
      end
    end

    context 'when no original_formatter is provided' do
      it 'creates a new Logger::Formatter' do
        formatter = described_class.new
        expect(formatter.original_formatter).to be_a(Logger::Formatter)
      end
    end
  end

  describe '#call' do
    let(:message) { 'test message' }

    before do
      allow(TruncateLog::Truncator).to receive(:truncate).and_return('truncated_message')
      allow(original_formatter).to receive(:call).and_return('formatted_message')
    end

    subject { formatter.call(severity, time, progname, message) }

    it 'truncates the message using Truncator' do
      subject
      expect(TruncateLog::Truncator).to have_received(:truncate).with('test message')
    end

    it 'formats the truncated message using the original formatter' do
      subject
      expect(original_formatter).to have_received(:call).with(severity, time, progname, 'truncated_message')
    end
  end
end
