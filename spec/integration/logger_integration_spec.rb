# frozen_string_literal: true

require 'spec_helper'
require 'logger'
require 'tempfile'
require 'truncate_log'
require 'json'

RSpec.describe 'Logger integration with TruncateFormatter' do
  let(:log_file) { Tempfile.new(['test_log', '.log']) }
  let(:logger) { Logger.new(log_file) }
  let(:large_string) { 'a' * 1000 }
  let(:large_array) { (1..100).to_a }
  let(:deep_hash) do
    {
      level1: {
        level2: {
          level3: {
            level4: {
              level5: {
                data: 'deep data',
                array: [1, 2, 3, 4, 5]
              }
            }
          }
        }
      }
    }
  end

  before do
    TruncateLog::Truncator.configure do |config|
      config.max_string_length = 20
      config.max_array_items = 5
      config.max_depth = 3
      config.max_item_size = 100
    end

    logger.formatter = TruncateLog::Formatter::TruncateFormatter.new
  end

  after do
    log_file.close
    log_file.unlink
  end

  def read_last_log_line
    log_file.rewind
    log_file.readlines.last&.strip
  end

  it '文字列が最大長さに切り詰められること' do
    logger.info(large_string)
    last_line = read_last_log_line

    expect(last_line).to include('aaaaa')
    expect(last_line).to include('more bytes omitted')
    expect(last_line).not_to include(large_string)
  end

  it '配列が最大要素数に切り詰められること' do
    logger.info(large_array)
    last_line = read_last_log_line

    expect(last_line).to include('1')
    expect(last_line).to include('more elements omitted')
    expect(last_line).not_to include('100')
  end

  it '深いネストのハッシュが適切に切り詰められること' do
    logger.info(deep_hash)
    last_line = read_last_log_line

    puts "実際のログ出力: #{last_line}"

    original_size = JSON.generate(deep_hash).size
    log_data_size = last_line.split(' -- : ').last.size

    expect(log_data_size).to be < original_size
    expect(last_line).to include('level1')
    expect(last_line).to include('level2')
  end

  it '通常のログフォーマット（時間、重要度など）が保持されること' do
    logger.info('Test message')
    last_line = read_last_log_line

    expect(last_line).to match(/I, \[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+ #\d+\]  INFO -- : Test message/)
  end

  context '異なるログレベルでも動作すること' do
    it 'DEBUGレベルで正しく動作すること' do
      logger.debug('Debug message')
      expect(read_last_log_line).to include('DEBUG')
      expect(read_last_log_line).to include('Debug message')
    end

    it 'WARNレベルで正しく動作すること' do
      logger.warn('Warning message')
      expect(read_last_log_line).to include('WARN')
      expect(read_last_log_line).to include('Warning message')
    end

    it 'ERRORレベルで正しく動作すること' do
      error_data = { error: 'Something went wrong', code: 500, details: { request_id: 'abc123', user_id: 42 } }
      logger.error(error_data)
      expect(read_last_log_line).to include('ERROR')
      expect(read_last_log_line).to include('Something went wrong')
    end
  end
end
