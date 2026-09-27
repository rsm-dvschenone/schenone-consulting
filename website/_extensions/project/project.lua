-- Shortcodes for case-study pages (work/<project>/index.qmd).
--
--   {{< project-meta >}}
--       The facts strip, services, stack and link buttons, read from the page's
--       front matter (client, year, role, status, services, stack, links,
--       offline-note). Put it first in the page body.
--
--   {{< project-embed url="https://…" image="cover.png" label="Launch the live demo" caption="…" >}}
--       A screenshot with a button; clicking loads the live site in an iframe
--       (small screens open it in a new tab instead). Script: reveal.html.

local function text(v)
  if v == nil then return nil end
  local s = pandoc.utils.stringify(v)
  if s == "" then return nil end
  return s
end

local function list(v)
  local out = {}
  if v == nil then return out end
  if pandoc.utils.type(v) == "List" then
    for _, x in ipairs(v) do
      local s = text(x)
      if s then table.insert(out, s) end
    end
  else
    local s = text(v)
    if s then table.insert(out, s) end
  end
  return out
end

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  s = s:gsub('"', "&quot;")
  return s
end

local function slug(s)
  return (s:lower():gsub("[^%w]+", "-"):gsub("^%-+", ""):gsub("%-+$", ""))
end

local function project_meta(_, _, meta)
  local html = {}
  local function add(s) table.insert(html, s) end

  add('<section class="project-meta">')

  -- Facts strip
  local facts = {
    { "Client", text(meta.client) },
    { "Year", text(meta.year) },
    { "Role", text(meta.role) },
    { "Status", text(meta.status) },
  }
  add('<dl class="facts project-facts">')
  for _, f in ipairs(facts) do
    if f[2] then
      local value = esc(f[2])
      if f[1] == "Status" then
        value = '<span class="project-status status-' .. slug(f[2]) .. '">' .. value .. "</span>"
      end
      add("<div><dt>" .. f[1] .. "</dt><dd>" .. value .. "</dd></div>")
    end
  end
  add("</dl>")

  -- Services + stack
  local services, stack = list(meta.services), list(meta.stack)
  if #services > 0 or #stack > 0 then
    add('<div class="project-cols">')
    if #services > 0 then
      add('<div><h2 class="project-label">Services provided</h2><ul class="project-services">')
      for _, s in ipairs(services) do add("<li>" .. esc(s) .. "</li>") end
      add("</ul></div>")
    end
    if #stack > 0 then
      add('<div><h2 class="project-label">Built with</h2><div class="chips">')
      for _, s in ipairs(stack) do add("<span>" .. esc(s) .. "</span>") end
      add("</div></div>")
    end
    add("</div>")
  end

  -- Links: first is the primary button
  local links = {}
  if meta.links and pandoc.utils.type(meta.links) == "List" then
    for _, l in ipairs(meta.links) do
      local label, url = text(l.label), text(l.url)
      if label and url then table.insert(links, { label = label, url = url }) end
    end
  end
  if #links > 0 then
    add('<div class="project-links">')
    for i, l in ipairs(links) do
      local cls = i == 1 and "btn-cta" or "btn-ghost"
      add('<a class="' .. cls .. '" href="' .. esc(l.url) .. '" target="_blank" rel="noopener">' .. esc(l.label) .. "</a>")
    end
    add("</div>")
  elseif text(meta["offline-note"]) then
    add('<p class="project-offline">' .. esc(text(meta["offline-note"])) .. "</p>")
  end

  add("</section>")
  return pandoc.RawBlock("html", table.concat(html, "\n"))
end

local function project_embed(_, kwargs)
  local url = text(kwargs.url)
  if not url then return pandoc.Null() end
  local image = text(kwargs.image)
  local label = text(kwargs.label) or "Launch the live demo"
  local caption = text(kwargs.caption)

  local html = {}
  local function add(s) table.insert(html, s) end
  add('<figure class="project-embed">')
  add('<div class="project-embed-frame" data-src="' .. esc(url) .. '" data-title="' .. esc(caption or label) .. '">')
  if image then add('<img src="' .. esc(image) .. '" alt="" loading="lazy">') end
  add('<button type="button" class="btn-cta project-embed-launch">' .. esc(label) .. "</button>")
  add("</div>")
  add("<figcaption>")
  if caption then add(esc(caption) .. " · ") end
  add('<a href="' .. esc(url) .. '" target="_blank" rel="noopener">Open in a new tab ↗</a>')
  add("</figcaption></figure>")
  return pandoc.RawBlock("html", table.concat(html, "\n"))
end

return {
  ["project-meta"] = project_meta,
  ["project-embed"] = project_embed,
}
