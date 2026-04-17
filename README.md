# RememberJCI (rememberit)

A memorization learning platform for Japanese JCI (Junior Chamber International) members. Practice the JCI declaration, creed, and local organization mottos with progressive cloze exercises, self-tests, and (shipping) voice recitation practice.

## Stack

- Ruby 3.2.2 / Rails 8.0.4
- PostgreSQL + Solid Queue / Solid Cache / Solid Cable
- Hotwire (Turbo + Stimulus) + ViewComponent + Tailwind v4
- Devise (`:confirmable`) + Pundit for auth / authorization
- PaperTrail for text versioning
- RSpec + FactoryBot + Shoulda Matchers for tests
- Deployment: Render (`render.yaml`, `plan: starter`) + Kamal configured as backup

## Getting started

```bash
bundle install
npm install
bin/rails db:prepare
bin/rails db:seed      # development JCI text placeholders
bin/dev                # runs Puma + esbuild + tailwindcss
```

Default dev user created by seeds: `admin@rememberjci.local` / `password` (admin role).

## Running tests

```bash
bundle exec rspec
```

839 examples as of v0.1.0.0. See `TESTING.md` (TBD) for the full test strategy and coverage goals.

## Shipping model

Versioned `MAJOR.MINOR.PATCH.MICRO` (see `VERSION` and `CHANGELOG.md`). Ship via the gstack `/ship` workflow: tests → coverage audit → adversarial review → PR.

## Feature status

- ✅ **v0.1** Group invite flow (Phase 1): LOM organizers issue tokenized invite URLs, members sign up and join in one step.
- ⏳ **v0.2** Voice / recitation MVP (Phase 2): record audio → Whisper transcription → Japanese-aware scoring.
- 🗓 **v1.1** Relay Mode: group-synchronous ceremonial recitation (see `~/.gstack/projects/YukiKudo03-RememberJCI/yukikudo-main-design-20260418-013609.md`).

## Planned hardening

See `TODOS.md`. Near-term priorities are a shared `rack-attack` cache store, token digest storage, `DESIGN.md` formalization, and closing the `skip_confirmation!` timing window.

## Licensing note for seed data

The JCI宣言 / JCI信条 / 日本JCI綱領 shipped in `db/seeds.rb` are **placeholder text** of the same shape as the real texts. The real texts are © 公益社団法人日本青年会議所 and require explicit permission before production use. See the comments at the top of `db/seeds.rb` for the canonical sources and the clearance flow.
