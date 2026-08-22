# Website — dominicschenone.com

Built with [Quarto](https://quarto.org) (same tool as the original UCSD site this was migrated from). Source pages are the `.qmd` files in this folder; `_quarto.yml` controls nav/theme. Rendering outputs to `../docs` at the repo root — **that output folder is what GitHub Pages actually serves.** Don't hand-edit anything under `/docs`; it's regenerated.

## To preview locally

```
quarto preview
```

## To build

```
quarto render
```

This regenerates `/docs` at the repo root. Commit both `/website` (source) and `/docs` (output) — Pages needs the built HTML in the repo, not just the source.

## GitHub steps still needed (manual, on github.com — not done yet)

The original site's repo (`rsm-dvschenone/Doms-Chill-Site`) is still tied to a school-affiliated GitHub account. Before this can go live under the new branding:

1. **Transfer repo ownership** — from the school account to your personal GitHub account (GitHub → repo → Settings → scroll to "Danger Zone" → Transfer ownership). This preserves the existing Pages config and `CNAME`.
2. **Rename the repo** post-transfer to something business-appropriate (e.g. `schenone-consulting-site`).
3. **Set repo visibility to private** — this only hides the source from public GitHub browsing; the published Pages site at `dominicschenone.com` stays public either way, since that's how Pages works regardless of repo visibility.
4. **Confirm Settings → Pages** still shows source = `main` branch, `/docs` folder, after the transfer+rename.
5. **Re-point this local working copy's git remote** to the transferred/renamed repo (`git remote set-url origin <new-url>`), then push.
6. **Verify `dominicschenone.com` resolves correctly** after the push — the CNAME/Cloudflare/GoDaddy DNS chain shouldn't need any changes, since it points at GitHub Pages generically rather than the old repo name.

None of the above has been done yet — this `/website` folder right now is just local source, not yet connected to any GitHub repo. Decide when you're ready to do the transfer, then it's a quick `git init` + remote + push here to go live.

## What got stripped from the original site

Homework/class content (`project_assignments/`), the Tennis dashboard, the resume PDF, and a handful of stray files (a leftover `pgweb` binary, Windows `Zone.Identifier` cruft) were dropped — none of it belonged on a business site. The headshot (`images/dom-headshot.jpg`) was kept for the About page. The `cosmo` Bootstrap theme and previously-empty `styles.css` were kept and built on.
