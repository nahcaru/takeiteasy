# Take it Easy (Unofficial)

> **履修登録をもっと簡単に** — Making course registration easier.

## 概要

学期の初めに履修する講義を決める際、考慮しなければならない情報が多く、参照すべき資料が分散していて履修計画の作成が大変であると感じたため、それを支援する Web サイトを作りました。

東京都市大学の学生向けに、講義の検索・時間割の作成・単位数の管理を一つの画面で行える Flutter Web アプリケーションです。

## 技術スタック

| レイヤー | 技術 |
|---|---|
| フレームワーク | Flutter (Web) |
| 状態管理 | Riverpod (`flutter_riverpod`) |
| 認証 | Firebase Auth (メール + Google OAuth) |
| データベース | Cloud Firestore (ユーザー設定・履修科目の保存) |
| ルーティング | `go_router` (パスベース URL) |
| テーマ | Material 3、Google Fonts (`M PLUS 1p`)、ライト/ダークモード |
| ホスティング | Firebase Hosting |

## 講義データの準備

講義データは以下の手順で用意しました：

1. **PDF 取得** — 大学のサイトから授業時間表 (PDF) をダウンロード
2. **スプレッドシート転写** — Google Apps Script で PDF から必要なデータをスプレッドシートに転写し、目視による確認の後 JSON 化
3. **スクレイピング** — Python でシラバスサイトをスクレイピングし、不足データ（分類・必選・単位数など）を JSON に追記
4. **サイトに取り込み** — JSON を Flutter で作ったサイトに `assets/data.json` として取り込み、Firebase Hosting で公開

## 主な機能

- **カリキュラム別フィルタリング** — 情報科学科・知能情報工学科の各年度・一般/国際コースに対応し、自分のカリキュラムに合った科目のみ表示
- **時間割ビルダー** — 週間グリッドで履修科目を視覚化、科目の重複を自動検出
- **単位数トラッカー** — カテゴリ別（教養・体育・外国語・PBL・情報工学基盤・専門・教職）の単位集計、修得済み単位の手動入力にも対応
- **スマート検索** — 科目名のオートコンプリート検索
- **多次元フィルター** — 学年・学期・分類・必選によるフィルタリング
- **空きコマ検索** — 履修済みの時間帯と重ならない科目のみ表示
- **シラバスリンク** — 各科目から大学公式シラバスページへ直接リンク
- **クラウド同期** — Firebase Auth でログインすると、履修科目・テーマ設定・カリキュラム選択が Firestore に保存される
- **レスポンシブデザイン** — モバイル（ポートレート）とデスクトップ（ランドスケープ）に対応した適応的レイアウト

## プロジェクト構成

```
lib/
├── main.dart                    # アプリ起点、ルーティング、テーマ、ナビゲーション
├── firebase_options.dart        # Firebase 設定（自動生成）
├── env/
│   ├── env.dart                 # 環境変数定義（Google Client ID）
│   └── env.g.dart               # 生成された難読化済み環境変数
├── models/
│   ├── course.dart              # 講義データモデル
│   ├── filter.dart              # フィルター状態モデル
│   └── user_data.dart           # ユーザー設定モデル
├── providers/
│   ├── course_list_provider.dart # 講義データの読み込み・フィルタリング
│   ├── filter_provider.dart     # フィルター状態管理
│   └── user_data_provider.dart  # 認証 + Firestore ユーザーデータ
├── screens/
│   ├── list_screen.dart         # 科目一覧画面
│   └── table_screen.dart        # 時間割・単位数画面
└── widgets/
    ├── choice_box.dart          # カリキュラム選択ドロップダウン
    ├── course_card.dart         # 科目リストカード
    ├── course_dialog.dart       # 科目詳細ダイアログ
    ├── credits_table.dart       # 単位数集計テーブル
    ├── filter_column.dart       # フィルター UI
    ├── search_box.dart          # 検索ボックス
    └── time_table.dart          # 時間割グリッド
```

## Getting Started

```bash
# 依存パッケージのインストール
flutter pub get

# 環境変数の生成（.env に webGoogleClientId を設定後）
dart run build_runner build

# 開発サーバー起動
flutter run -d chrome
```
