# Changelog

All notable changes to this project are documented here.
Format is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and uses a 4-digit `MAJOR.MINOR.PATCH.MICRO` version scheme.

## [0.1.0.0] - 2026-04-18

### Added
- Group invite flow for LOM (Local Organization of Members) presidents. A group owner can now open "招待リンク" from their group page, issue a tokenized invite URL, and share it via LINE/Slack/メール. The invited member visits `/join/:token`, signs up (or joins from an existing account), and lands in the group dashboard without needing to click an email confirmation link.
- `GroupInvite` model with soft-delete failure semantics (`revoked_at`), per-invite expiry, and a uses budget (`max_uses` / `uses_count`). Atomic consume via a single guarded UPDATE so concurrent accepts cannot over-consume or consume a just-revoked invite.
- Status pill component (`StatusBadgeComponent`) showing 有効 / 期限切れ / 失効済み / 使い切り with color + text so the state is legible for screen readers and color-blind users.
- Clipboard copy action on the invite index page with a three-tier fallback: `navigator.clipboard.writeText` → `execCommand('copy')` → visible manual-copy text field with Cmd+C / Ctrl+C prompt. Never silent on denial.
- Japanese sample seeds for JCI宣言 / JCI信条 / 日本JCI綱領 (placeholder text while the real copyrighted text awaits clearance from 公益社団法人日本青年会議所).
- `invite_create/ip` rack-attack throttle (10/min per IP) as defense-in-depth on top of the global 300/5min rule.
- Full i18n for invite flow (`group_invites.*`, `join_invites.*`) in `config/locales/ja.yml`.

### Changed
- `Group#add_member` rewritten from `members << user unless members.include?(user)` to `find_or_create_by!` with `RecordNotUnique` rescue. Safe under concurrency, backed by a new composite unique index on `group_memberships(user_id, group_id)`.
- `Users::RegistrationsController#create` now auto-confirms and auto-joins the group when sign-up follows an active invite link (skip_confirmation! before save). The normal sign-up flow is unchanged and regression-tested.

### Fixed
- Concurrent accept race on `max_uses=1` invites: two simultaneous submits no longer both get membership. Consume + membership insert now run in one transaction with a row lock.
- Silent data loss where a membership insert failure (DB hiccup, unique violation) would leave the invite use consumed without membership. Consume is now rolled back on any membership failure.
