# LabWiki

Source for the SHU SIT Lab's cluster documentation site (DGX Spark / Slurm /
Enroot / Pyxis), built with
[MkDocs Material](https://squidfunk.github.io/mkdocs-material/) and
published via GitHub Pages.

Repo: https://github.com/SHU-SIT-Lab/LabWiki

## One-time setup

1. In the GitHub repo, go to **Settings → Pages** and set:
   - **Source:** "Deploy from a branch"
   - **Branch:** `gh-pages` / `(root)`

   (The `gh-pages` branch will be created automatically the first time the
   GitHub Actions workflow runs — see below — so do step 4 first if the
   branch doesn't exist yet.)

4. In **Settings → Actions → General → Workflow permissions**, make sure
   "Read and write permissions" is enabled, so the deploy workflow is
   allowed to push to `gh-pages`.

5. Push to `main` (or re-run the workflow from the **Actions** tab). After it
   finishes, the site will be live at:

   ```
   https://SHU-SIT-Lab.github.io/LabWiki/
   ```

## Editing the docs

See [`docs/contributing.md`](docs/contributing.md) — or once the site is
live, its "Contributing to These Docs" page.

## Local preview

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
mkdocs serve
```

Then visit `http://127.0.0.1:8000`.
