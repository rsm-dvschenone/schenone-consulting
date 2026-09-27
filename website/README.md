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

Then commit **both** `website/` (source) and `docs/` (output) and push. Pages only serves what's in `docs/` on `main`.

Quarto prints a warning that it's "refusing to remove docs/site_libs". That's expected, because the output folder is outside the project, and it's harmless. It also means **deleted pages aren't cleaned out of `docs/` automatically**, so delete the stale `.html` by hand.

---

## Going live: transfer the old repo and publish

The old site lives in `rsm-dvschenone/Doms-Chill-Site` on the school-affiliated GitHub account. This local repo has its own separate history and **no remote yet**. The plan: move the old repo to your personal account, replace its contents with this repo, and point Pages and DNS at it.

### Step 0: Decide public vs. private (this affects cost)

This repo holds more than the site. It also has `internal/docs/` (pricing, tax, and strategy notes), `product/` (connector code), and `clients/`.

- **GitHub Pages on a *private* repo requires a paid plan** (GitHub Pro, about $4/mo). On the free plan, Pages only works on public repos, and making a Pages repo private unpublishes the site.
- A **public** repo would expose all of the internal material above to anyone.

**Recommended:** GitHub Pro plus a private repo. It's the least work, and everything stays together. (Alternative: a free public repo containing only `website/` and `docs/`, with the business material in a separate private repo. More setup, so only worth it if you want to avoid the $4/mo.)

### Step 1: Commit the current work locally (WSL)

```bash
cd ~/"Dom's Side Projects/Schenone Consulting"
git status                      # sanity check: no .env or client data listed
git add -A
git commit -m "Reposition site: web, BI & data engineering; full visual redesign"
```

### Step 2: Prepare your personal GitHub account

1. Sign in to (or create) your **personal** GitHub account and turn on two-factor authentication (Settings → Password and authentication).
2. If going private, upgrade to **GitHub Pro** (Settings → Billing and plans) **before** step 4.
3. Set up authentication from WSL:
   ```bash
   sudo apt update && sudo apt install gh -y
   gh auth login                 # choose GitHub.com → HTTPS → login with a web browser
   gh auth setup-git
   ```

### Step 3: Transfer the old repo from the school account

1. Sign in to the **school account** (`rsm-dvschenone`) and open `Doms-Chill-Site`.
2. Before you transfer, note two things in **Settings → Pages**: the **branch** Pages publishes from (`main` or `master`) and the **custom domain** field.
3. Go to **Settings → General → Danger Zone → Transfer ownership**. Enter your personal username, type the repo name to confirm, and click **I understand, transfer this repository**.
4. GitHub emails your **personal** account a transfer request. Accept it; the link expires after a day.
   - If the repo sits under a school **organization** rather than the `rsm-dvschenone` user, you need owner rights in that org. If you don't have them, skip the transfer: create a new repo in step 4 instead, and **remove the custom domain from the old repo's Pages settings first**, or GitHub will say the domain is already taken.

### Step 4: Rename and set visibility (on your personal account)

1. Open the transferred repo → **Settings → General → Repository name**. Rename it to something like `schenone-consulting` (it holds the whole business, not just the site).
2. In the **Danger Zone**, change visibility to **Private** (Pro required to keep Pages running; see step 0).

### Step 5: Push this repo over the old content

The old repo's history is unrelated to this one, so this is a force-push. First, save the old site on a branch so nothing is lost.

```bash
cd ~/"Dom's Side Projects/Schenone Consulting"
git remote add origin https://github.com/<your-username>/schenone-consulting.git
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
2. **Custom domain:** `dominicschenone.com` → Save. (The `docs/CNAME` file already contains this, but check the field isn't blank after the transfer.)
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
| CNAME | `www` | `<your-username>.github.io` | DNS only |

- **The `www` record almost certainly needs to change.** It currently points at `rsm-dvschenone.github.io`, and it has to point at your *new* username. The A records probably don't need to change.
- Keep the records set to **DNS only** (grey cloud), at least until GitHub has issued the HTTPS certificate. Cloudflare's proxy blocks GitHub's certificate check. If you later turn the proxy on, set Cloudflare **SSL/TLS mode to Full**. "Flexible" causes redirect loops.
- Optional: add AAAA records for IPv6: `2606:50c0:8000::153`, `2606:50c0:8001::153`, `2606:50c0:8002::153`, `2606:50c0:8003::153`.

Check from WSL:

```bash
dig +short dominicschenone.com          # should list the four 185.199.x.153 IPs
dig +short www.dominicschenone.com      # should show <your-username>.github.io
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
