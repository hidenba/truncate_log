# TruncateLog

大きなログデータを自動的に切り詰めるRuby gem。ログ出力の際に大きすぎるデータ構造を自動で切り詰め、ログの肥大化を防ぎます。

TruncateLogは、ログに出力されるハッシュ、配列、文字列などのデータ構造が大きくなりすぎるのを防ぎ、ログの可読性を向上させ、ストレージの使用量を抑えます。JSON形式のログフォーマットにも対応しています。

## 特徴

- 大きなデータ構造（ハッシュ、配列、文字列）を自動的に切り詰め
- 深いネストされたデータ構造も適切に処理
- カスタマイズ可能な切り詰めの設定
- Ruby標準のLoggerクラスに統合可能
- SemanticLoggerとの連携機能

## インストール

Gemfileに以下を追加:

```ruby
gem 'truncate_log'
```

そして以下を実行:

```bash
$ bundle install
```

または直接インストール:

```bash
$ gem install truncate_log
```

## 使い方

### 基本的な使い方

```ruby
require 'truncate_log'

# 大きなデータ構造
large_data = {
  array: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
  nested: {
    deep: {
      deeper: {
        deepest: 'a' * 1000
      }
    }
  }
}

# データを切り詰める
truncated_data = TruncateLog::Truncator.truncate(large_data)
puts truncated_data.to_json
```

### 設定のカスタマイズ

```ruby
TruncateLog::Truncator.configure do |config|
  # 最大項目サイズ（バイト）
  config.max_item_size = 2048      # デフォルト: 1024

  # 文字列の最大長
  config.max_string_length = 1024  # デフォルト: 512

  # 配列の最大項目数
  config.max_array_items = 10      # デフォルト: 5

  # ハッシュの最大キー数
  config.max_hash_keys = 20        # デフォルト: 10

  # ネストの最大深度
  config.max_depth = 8             # デフォルト: 5
end
```

### Loggerと統合する

```ruby
require 'logger'
require 'truncate_log'

# Loggerを作成
logger = Logger.new(STDOUT)

# TruncateLogのフォーマッタを設定
logger.formatter = TruncateLog::Formatter::TruncateFormatter.new

# 大きなデータを含むログを出力
logger.info("Large data") { large_hash_or_array }  # 自動的に切り詰められる
```

### SemanticLoggerと統合する

```ruby
require 'semantic_logger'
require 'truncate_log'

# SemanticLoggerの設定
SemanticLogger.default_level = :info
SemanticLogger.add_appender(
  io: STDOUT,
  formatter: TruncateLog::Formatter::SemanticLogger::Truncate.new
)

# ロガーの作成
logger = SemanticLogger['MyApp']

# 大きなデータを含むログを出力
logger.info(message: 'Large payload', payload: large_data)  # 自動的に切り詰められる
```

## 開発

リポジトリをクローンした後、`bin/setup`を実行して依存関係をインストールします。
テストを実行するには`rake spec`を実行します。
対話型のプロンプトでコードを試すには`bin/console`を使用します。

## 貢献

バグレポートやプルリクエストはGitHubで歓迎しています: https://github.com/[USERNAME]/truncate_log

## ライセンス

このgemはMITライセンスの下で利用可能です。
