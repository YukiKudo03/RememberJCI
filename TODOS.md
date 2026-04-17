# TODOs

## v1.1 (週末Phase 1/2完了後)

### DESIGN.md の正式化 ( /design-consultation 実行 )
**What**: プロジェクトルートに `DESIGN.md` を作成し、暗黙のTailwind design system (indigo-600 primary, gray neutral, Heroicons 20x20, ViewComponent 命名パターン) を明文化。加えて新規 `StatusBadgeComponent` の variant仕様、FlashComponent のrole使い分け、モバイルテーブル→カードstack方針を記録。

**Why**: Phase 2 (音声MVP) で新しい画面・コンポーネントを作る時、"既存システムに合わせて"が曖昧なままだと AI 実装が generic Tailwind パターンに流れやすい。DESIGN.md があると CC に参照してもらえる。

**Pros**: Phase 2以降の全UI実装品質が安定 / 将来ユーザーを増やすときのonboarding資料 / `/plan-design-review` の Pass 5 精度向上。
**Cons**: 1-2時間の作業 / DESIGN.md作成中に"まだ決まっていない"判断が表出してPhase 2を遅らせる可能性。

**Context**: 今回のdesign reviewは暗黙systemから抽出して実施したが、次回以降は DESIGN.md 参照の方が早い。`/design-consultation` が対話形式で生成する。

**Depends on**: Phase 1 完了後、Phase 2 着手前の理想的タイミング。

### rack-attack の cache store を Solid Cache に切替
**What**: `Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new` (`config/initializers/rack_attack.rb:8`) を `Rails.cache` (Solid Cache) に変更。

**Why**: 現状 MemoryStore はプロセス内shared。マルチプロセス (Puma worker複数 / Render scaling) で throttle counter が共有されず、実質的にrate limitが機能しない状態になる。

**Pros**: 本番環境で意図通りの rate limit が効く / Solid Cache は Rails 8 標準、追加依存なし。
**Cons**: Solid Cache init order を確認する必要あり (rack_attack.rb がcache読む時にcacheが準備済みか)。

**Context**: 現状 Render `starter` plan は単一instance想定だが、将来スケールアウト時に無音で壊れる。1行変更で予防可能。

**Depends on**: Phase 1 完了後いつでも (blocking なし)。

---

### 招待トークンの digest化 (security hardening)
**What**: `GroupInvite.token` (平文) を `token_digest` (SHA256) + URL上は平文token のみ。検証時は `Digest::SHA256.hexdigest(params[:token])` と DB 一致確認。

**Why**: DBバックアップ漏れ・ログ漏れ時の招待URL悪用リスクを下げる。`has_secure_password` と同じ defense-in-depth パターン。

**Pros**: DB漏洩時の影響範囲縮小 / 将来の"公開SaaS化"検討時のブロッカー解消。
**Cons**: `has_secure_token` は平文保存前提、自前実装必要 / テスト複雑化 / 平文tokenの扱い（生成直後にのみアクセス可）。

**Context**: JCI内輪スケール (数十〜数百人) ではリスクは低いが、将来"公開・複数LOM対応・他団体展開"を検討するなら必須。

**Depends on**: GroupInvite model の初期実装完了後。破壊的変更 (DB schema + 平文token扱い) のため新規実装後まで手を付けない。
