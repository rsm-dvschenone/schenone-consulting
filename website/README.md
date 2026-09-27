# Website — dominicschenone.com

Built with [Quarto](https://quarto.org). Source pages are the `.qmd` files in this folder; `_quarto.yml` controls nav, footer, and theme; `styles.css` holds the whole design system. Rendering outputs to `../docs` at the repo root — **that output folder is what GitHub Pages actually serves.** Don't hand-edit anything under `/docs`; it's regenerated.

| File | What it is |
|---|---|
| `index.qmd`, `services.qmd`, `approach.qmd`, `about.qmd`, `contact.qmd` | Pages (mostly raw HTML blocks using the classes in `styles.css`) |
| `styles.css` | Design tokens (light on `:root`, dark on `body.quarto-dark`) + all components |
| `fonts.html` | Google Fonts: Instrument Serif (display), Inter (body), JetBrains Mono (labels) |
| `reveal.html` | Small scroll-in animation script; page is fully visible without it |

## Day-to-day workflow

Run these from WSL, in this `website/` folder.

```bash
quarto preview        # live-reloading local preview
quarto render         # rebuild ../docs
```

**If you changed `styles.css`, bump the `?v=` number in `fonts.html`** before rendering. The site sits behind Cloudflare, and browsers cache the stylesheet for 4 hours; without the bump, visitors see new pages with an old stylesheet.

Then commit **both** `website/` (source) and `docs/` (output) and push. Pages only serves what's in `docs/` on `main`.

Quarto prints a warning that it's "refusing to remove docs/site_libs". That's expected, because the output folder is outside the project, and it's harmless. It also means **deleted pages aren't cleaned out of `docs/` automatically**, so delete the stale `.html` by hand.

---

## Going live: publish from the existing account

**Decision (2026-09-26):** keep using the existing GitHub account (`rsm-dvschenone`) and the existing repo `Doms-Chill-Site`, and keep the repo **public** (free plan). No transfer needed. This local repo has its own separate history and **no remote yet**, so the plan is: rename the old repo, push this repo over it, and confirm the Pages and DNS settings.

**Public means** everything in the repo, `internal/docs/` included (pricing, tax, strategy), is readable by anyone. To lock it down later: GitHub Pro (about $4/mo), then Settings → Danger Zone → change visibility to Private. Pages keeps running on Pro, but anything already cloned stays out there.

### Step 1: Commit locally ✅ done

### Step 2: Secure the account and connect WSL

1. Sign in as `rsm-dvschenone`. Under **Settings → Emails**, add your personal email (e.g. Gmail) and make it the **primary** address. If the school email is ever deactivated, a school-only account can't reset its password, and you'd lose control of the repo and the domain setup.
2. Under **Settings → Password and authentication**, turn on two-factor authentication and save the recovery codes somewhere safe.
3. Optional: rename the account to something business-appropriate under **Settings → Account → Change username**. If you do, the `www` CNAME in step 7 must change to the new `<username>.github.io`.
4. Set up authentication from WSL:
   ```bash
   sudo apt update && sudo apt install gh -y
   gh auth login                 # GitHub.com → HTTPS → login with a web browser
   gh auth setup-git
   ```

### Step 3: Note the current Pages settings

Open `Doms-Chill-Site` → **Settings → Pages** and write down:

- the **branch** it publishes from (`main` or `master`), and the folder (`/docs` or root)
- the **custom domain** field (should be `dominicschenone.com`)

### Step 4: Rename the repo

**Settings → General → Repository name** → `schenone-consulting` (it holds the whole business, not just the site). GitHub redirects the old URL automatically.

### Step 5: Push this repo over the old content

The old repo's history is unrelated to this one, so this is a force-push. First, save the old site on a branch so nothing is lost.

```bash
cd ~/"Dom's Side Projects/Schenone Consulting"
git remote add origin https://github.com/rsm-dvschenone/schenone-consulting.git
git fetch origin

# Keep the old site's history on a branch. Use origin/master if that's what step 3 showed.
git push origin origin/main:refs/heads/legacy-site

# Replace main with this repo
git push --force-with-lease=main:origin/main -u origin main
```

If the old default branch was `master`, go to **Settings → General → Default branch**, switch it to `main`, then delete `master`.

### Step 6: Configure GitHub Pages

In the repo, go to **Settings → Pages**:

1. **Source:** Deploy from a branch → Branch **`main`**, folder **`/docs`** → Save.
2. **Custom domain:** `dominicschenone.com` → Save. (The `docs/CNAME` file already contains this, but check the field isn't blank.)
3. Wait for the DNS check to pass (step 7), then tick **Enforce HTTPS**. The certificate can take up to about an hour to appear.
4. **Verify the domain** so no one else can claim it: your profile → **Settings → Pages → Add a domain**. GitHub gives you a TXT record to add in Cloudflare. Add it, then click Verify.

Each push to `main` triggers a "pages build and deployment" run under the repo's **Actions** tab. A green check means it's live.

### Step 7: DNS in Cloudflare

The registrar is GoDaddy, with nameservers on Cloudflare, so edit the records in **Cloudflare → dominicschenone.com → DNS**:

| Type | Name | Content | Proxy |
|---|---|---|---|
| A | `@` | `185.199.108.153` | DNS only (grey cloud) |
| A | `@` | `185.199.109.153` | DNS only |
| A | `@` | `185.199.110.153` | DNS only |
| A | `@` | `185.199.111.153` | DNS only |
| CNAME | `www` | `rsm-dvschenone.github.io` | DNS only |

- **These records are probably already correct**, since the account isn't changing. Just confirm they match, and that `www` points at `rsm-dvschenone.github.io` (or your new username if you renamed the account in step 2).
- Keep the records set to **DNS only** (grey cloud), at least until GitHub has issued the HTTPS certificate. Cloudflare's proxy blocks GitHub's certificate check. If you later turn the proxy on, set Cloudflare **SSL/TLS mode to Full**. "Flexible" causes redirect loops.
- Optional: add AAAA records for IPv6: `2606:50c0:8000::153`, `2606:50c0:8001::153`, `2606:50c0:8002::153`, `2606:50c0:8003::153`.

Check from WSL:

```bash
dig +short dominicschenone.com          # should list the four 185.199.x.153 IPs
dig +short www.dominicschenone.com      # should show rsm-dvschenone.github.io
```

### Step 8: Verify the live site

- [ ] `https://dominicschenone.com` loads with a padlock, and `http://` and `www.` both redirect to it
- [ ] All five pages work from the nav, and no old "Why It Matters" page is reachable
- [ ] The dark-mode toggle (top right) works
- [ ] It looks right on a phone
- [ ] The contact email works (see below)

### Before announcing: set up the real inbox

`hello@dominicschenone.com` is still a placeholder. It appears in `contact.qmd` and in the footer in `_quarto.yml`. The quickest option is **Cloudflare → Email → Email Routing**, which is free: forward `hello@` to your personal inbox. If you'd rather use a different address, change both files, run `quarto render`, commit, and push.

---

## What got stripped from the original site

Homework/class content (`project_assignments/`), the Tennis dashboard, the resume PDF, and a handful of stray files (a leftover `pgweb` binary, Windows `Zone.Identifier` cruft) were dropped; none of it belonged on a business site. The headshot (`images/dom-headshot.jpg`) was kept for the About page. That content is still reachable on the `legacy-site` branch after step 5.