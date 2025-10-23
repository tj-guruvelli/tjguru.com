# GuruGuardian — The Knowledge Archives

Welcome to the vault where curiosity wears a cape. This is the public codex of GuruGuardian — a living archive of notes, write‑ups, and field reports spanning cybersecurity, Georgia Tech OMSCyber coursework, engineering, and personal explorations. Built with Jekyll + Chirpy, deployed by GitHub Pages, and defended against the forces of chaos by automation and good taste.

## The Story So Far

In a world crowded by noise, the Guardian seeks signal. Each post is a recovered artifact; each page, a mapped corridor of understanding. The aim is simple: preserve hard‑won knowledge with enough structure that Future‑You (and the world) can actually find and reuse it.

## Cast of Characters

- Hero — GuruGuardian: cataloger of truth, breaker of vague notes
- Allies — Evidence, Reproducibility, Clear Taxonomy, Good Contrast
- Villains —
  - The Noise: misinformation and half‑remembered snippets
  - The Metadata Phantom: YAML leaking into the page body
  - The Contrast Goblins: unreadable dark‑mode links and sidebars
  - The Doppelgänger: duplicate categories (Gatech inside Gatech)
  - Link Rot Hydra: images and URLs that decay without care

## Map of the Realm (repo layout)

- `_posts/` — canonical notes and write‑ups (e.g., `gatech/`, `cybersecurity/`)
- `_layouts/`, `_includes/`, `_sass/` — theme structure and styles (Chirpy)
- `_data/` — site data (socials, locale text, etc.)
- `assets/` — images, media, and generated artifacts
- `.github/workflows/pages-deploy.yml` — the Pages deployment spell
- `_config.yml` — site settings (permalinks, baseurl, archives, plugins)

## Powers and Artifacts (how this site works)

- Static site generator: Jekyll (Markdown → HTML)
- Theme: Chirpy, customized with Georgia Tech‑inspired palette
- Auto‑indexing: jekyll‑archives for categories and tags
- Aggregator posts: parent “module” pages that include child posts using Liquid `include_relative` with YAML stripping (so metadata never leaks)
- Taxonomy: organized to keep navigation sane
  - Gatech → Courses (and Notes)
  - Knowledge → Cybersecurity, Engineering, Personal

## Run the Lair Locally

With Ruby/Bundler:

```bash
bundle install
bundle exec jekyll serve --livereload
```

With Docker (if provided):

```bash
docker-compose up -d --build
```

Site appears at `http://localhost:4000` (for project sites, paths include the `baseurl`).

## Summon a New Entry (add a post)

1. Create a file under `_posts/<category>/YYYY-MM-DD-title.md`
2. Add front matter:

```yaml
---
title: Your Post Title
date: 2025-01-01 00:00:00 +0000
categories: [Gatech, Courses] # or [Knowledge, Cybersecurity]
tags: [omscyber, notes]
toc: true
---
```

3. Drop images in `assets/img/...` and reference them with absolute paths (e.g., `/assets/img/cybersecurity/example.png`).
4. Commit and push. Actions will build and publish.

### Aggregated “Module” Posts

Parent posts can stitch multiple child files into one readable page while stripping child YAML to avoid leaks:

```liquid
{% capture raw %}{% include_relative 2025-01-01-child.md %}{% endcapture %}
{% assign parts = raw | split: '---' %}
{{ parts[2] }}
```

## Deployments (Pages)

- Build: GitHub Actions (`pages-deploy.yml`)
- Project‑site URLs: `url: https://tj-guruvelli.github.io`, `baseurl: "/tjguru.com"`
- User‑site URLs (if using `username.github.io`): set `baseurl: ""`
- Optional custom domain: add `CNAME` with your domain and switch `url` accordingly

## Field Guide to Common Villains

- Metadata Phantom — Fix by validating front matter, or strip YAML when including children.
- Doppelgänger Categories — Standardize order: `[Gatech, Courses]` (not `[Courses, Gatech]`).
- Contrast Goblins — Keep dark‑mode text readable; links and sidebars must meet contrast.
- Link Rot Hydra — Prefer repo‑local assets; avoid brittle external links when possible.

## Yin and Yang (☯) of the Archives

- Yin — reflection, fundamentals, reproducibility | Yang — action, experiments, shipping
- Yin — defense (hardening, policy) | Yang — offense (red teaming, exploit demos)
- Yin — structure (categories, tags) | Yang — narrative (story‑first posts)
- Yin — stability (URLs, assets, versioning) | Yang — evolution (edits, new modules)
- Yin — depth (long‑form notes) | Yang — clarity (diagrams, summaries)

The GuruGuardian keeps both in balance so knowledge stays alive and usable.

## Credits

- Theme: [Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy)
- Built with Jekyll, deployed via GitHub Pages

May these archives serve your future quests. Guard the knowledge; be the GuruGuardian.
