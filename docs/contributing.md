# Contributing to These Docs

These docs are just Markdown files in the `docs/` folder of this repo,
built with [MkDocs](https://www.mkdocs.org/) and the
[Material theme](https://squidfunk.github.io/mkdocs-material/). Anyone in
the lab can edit them.

## Quick edits (no local setup)

Click the pencil/edit icon at the top of any page (or edit the file directly
on GitHub), commit to a new branch, and open a pull request. GitHub will
show you a live diff.

## Editing locally

```bash
git clone https://github.com/YOUR-ORG/YOUR-REPO.git
cd YOUR-REPO
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
mkdocs serve
```

Then open `http://127.0.0.1:8000` — it live-reloads as you edit files in `docs/`.

## Publishing

Just merge to `main`. A GitHub Actions workflow
(`.github/workflows/deploy.yml`) automatically rebuilds and redeploys the
site to GitHub Pages on every push to `main`.

## Adding a new page

1. Create a new `.md` file under `docs/`
2. Add it to the `nav:` section of `mkdocs.yml`
3. Open a PR
