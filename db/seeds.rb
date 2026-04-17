# frozen_string_literal: true

# Idempotent seeds for local development and staging.
#
# JCI texts (JCI宣言 / JCI信条 / 綱領) are copyrighted by 公益社団法人日本青年会議所.
# Seeding the actual text without explicit permission risks a rights issue for
# anyone running `bin/rails db:seed` — so the dev seeds ship placeholder text
# that mirrors the SHAPE (length, line count, cadence) for realistic practice
# UX testing. For production, the real text is loaded via the admin UI (or a
# separate seed script run by someone who has cleared licensing).
#
# Reference (not the text itself, just the canonical source):
#   JCI宣言  → https://www.jci.jp/
#   JCI信条  → https://www.jci.jp/
#   日本JCI綱領 → https://www.jaycee.or.jp/
#
# Review before copying the real text into production.

return if Rails.env.production?

# A seed admin so that seed Texts have a created_by owner.
admin = User.find_or_create_by!(email: "admin@rememberjci.local") do |u|
  u.name = "開発用管理者"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :admin
  u.confirmed_at = Time.current
end

placeholder_texts = [
  {
    title: "【開発用サンプル】JCI宣言",
    content: <<~TEXT,
      これは開発・学習用のサンプルテキストです。
      本番環境では、公益社団法人日本青年会議所の許諾を得たうえで
      正式な JCI 宣言のテキストを投入してください。

      若き英知と勇気と情熱をもって、社会に奉仕する人を育て、
      よりよい社会を築くために行動することを、ここに誓う。
    TEXT
    difficulty: :medium
  },
  {
    title: "【開発用サンプル】JCI信条",
    content: <<~TEXT,
      これは開発・学習用のサンプルテキストです。
      本番環境では、公益社団法人日本青年会議所の許諾を得たうえで
      正式な JCI 信条のテキストを投入してください。

      我々は信じる、
      信仰は、人生に意義と目的を与えることを。
      人類の同胞愛は、国家の主権を超越することを。
      経済の正義は、自由な人々によって、自由な企業を通して
      もっともよく達成されることを。
      人間の個性は、この世における最も尊いものであることを。
      人類への奉仕こそ、人生の最も価値ある業(わざ)であることを。
    TEXT
    difficulty: :hard
  },
  {
    title: "【開発用サンプル】日本JCI綱領",
    content: <<~TEXT,
      これは開発・学習用のサンプルテキストです。
      本番投入は正式な綱領テキストに差し替えてください。

      われわれ青年会議所は、社会的、国家的、国際的理解のもとに、
      青年としての英知と勇気と情熱をもって、
      明るい豊かな社会を築きあげよう。
    TEXT
    difficulty: :easy
  }
]

placeholder_texts.each do |attrs|
  Text.find_or_create_by!(title: attrs[:title]) do |t|
    t.content = attrs[:content]
    t.difficulty = attrs[:difficulty]
    t.created_by = admin
  end
end

puts "Seeded #{Text.count} texts (placeholder content — see db/seeds.rb for licensing note)."
