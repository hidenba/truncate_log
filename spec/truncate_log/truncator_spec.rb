# frozen_string_literal: true

require 'debug'

RSpec.describe TruncateLog::Truncator do
  describe '.truncate' do
    before do
      TruncateLog::Truncator.configure do |config|
        config.max_item_size = 256
        config.max_string_length = 128
        config.max_array_items = 2
        config.max_depth = 3
        config.max_hash_keys = 2
      end
    end
    subject { described_class.truncate(data) }

    context '小さなデータ構造の場合' do
      context '小さな文字列はそのまま返す' do
        let(:data) { 'hello world' }

        it { is_expected.to eq(data) }
      end

      context '小さな配列はそのまま返す' do
        let(:data) { %w[1 2 3] }

        it { is_expected.to eq(data) }
      end

      context '小さなハッシュはそのまま返す' do
        let(:data) { { a: 1, b: 2, c: 3 } }

        it { is_expected.to eq(data) }
      end
    end

    context '大きな文字列の場合' do
      let(:data) { 'a' * 3000 }

      it { is_expected.to start_with('a' * 128) }
      it { is_expected.to include('more bytes omitted') }
      it { expect(subject.bytesize).to be < data.bytesize }
    end

    context '大きな配列の場合' do
      let(:data) { (1..5).to_a.map { |i| 'x' * 100 + i.to_s } }

      it { expect(subject.size).to eq 3 }
      it { expect(subject.last).to be_a(String) }
      it { expect(subject.last).to include('more elements omitted') }
    end

    context 'ネストされたデータ構造の場合' do
      let(:data) do
        {
          array: [1, 2, { nested: 'x' * 5000 }],
          hash: { a: 1, b: 'y' * 5000 }
        }
      end

      let(:nested) { subject.dig(:array, 2, :nested) }
      let(:nested_hash) { subject.dig(:hash, :b) }

      it { expect(nested).to be_a(String) }
      it { expect(nested.size).to be < 5000 }
      it { expect(nested).to include('more bytes omitted') }

      it { expect(nested_hash).to be_a(String) }
      it { expect(nested_hash.size).to be < 5000 }
      it { expect(nested_hash).to include('more bytes omitted') }
    end

    context '最大深度に達した場合' do
      subject { described_class.truncate(data, 0, 3) }

      context '配列の場合は概要情報を返す' do
        let(:data) { [[[[[[[[1, ('x' * 10_000), 3]]]]]]]] }

        it { expect(subject[0][0][0]).to be_an(Array) }
        it { expect(subject[0][0][0].size).to eq 1 }
        it { expect(subject[0][0][0][0]).to include('Array too large, omitted') }
      end

      context 'ハッシュの場合は概要情報を返す' do
        let(:data) { { a: { b: { c: { d: { e: { f: { g: ('x' * 10_000) } } } } } } } }

        it { expect(subject.dig(:a, :b, :c)).to be_a(Hash) }
        it { expect(subject.dig(:a, :b, :c, :summary)).to include('Hash too large, omitted') }
      end
    end

    context 'threshold_multiplierが小さい場合' do
      subject { described_class.truncate(data, 0, 10, 0.05) }

      let(:data) { 'x' * 3000 }

      it 'しきい値が低すぎる場合は元のデータを返す' do
        expect(subject).to eq(data)
      end
    end

    context '大きなハッシュの場合' do
      let(:data) do
        hash = {}
        15.times do |i|
          hash["key#{i}"] = "value#{i}" * 100 * i
        end
        hash
      end

      it 'ハッシュのすべてのキーを保持する' do
        expect(subject.keys).to match_array(data.keys)
      end

      it '大きな値が切り捨てられる' do
        expect(subject['key5']).to include('more bytes omitted')
      end
    end

    context '例外が発生した場合' do
      before do
        allow(described_class).to receive(:data_size).and_raise(StandardError.new('テストエラー'))
        # allow(Rails.logger).to receive(:warn)
      end

      let(:data) { { test: 'value' } }

      it '元のデータを返す' do
        expect(subject).to eq(data)
      end
    end

    context 'サイズ上限を超えてしまう場合' do
      let(:data) do
        {
          a: [
            { a1: 'a' * 2000, a2: 'b' * 2000 },
            { a1: 'a' * 2000, a2: 'b' * 2000 },
            { a1: 'a' * 2000, a2: 'b' * 2000 },
            { a1: 'a' * 2000, a2: 'b' * 2000 },
            { a1: 'a' * 2000, a2: 'b' * 2000 },
            { a1: 'a' * 2000, a2: 'b' * 2000 },
            { a1: 'a' * 2000, a2: 'b' * 2000 },
            { a1: 'a' * 2000, a2: 'b' * 2000 }
          ]
        }
      end

      it do
        expect(subject.dig(:a, 1, :summary)).to include('Hash too large, omitted')
      end
    end
  end
end
