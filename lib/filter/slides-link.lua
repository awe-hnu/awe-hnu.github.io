-- slides-link.lua
-- For HTML pages whose front matter also lists a reveal.js format, writes
-- the slides file name into the page head:
--
--   <meta name="awe-slides" content="slides.html">
--
-- lib/theme/awe-web.html reads it to show the Slides / Print slides buttons
-- immediately (no request to the server). The file name comes from the
-- revealjs block's `output-file`, default slides.html.
--
-- It also writes the title of the sidebar that lists the page (from
-- _quarto.yml), which Quarto does not print when the site has a navbar:
--
--   <meta name="awe-sidebar-title" content="Advanced Paper Writing">
--
-- `page-meta: false` in the front matter hides the author bar and the
-- action buttons (e.g., on the start page):
--
--   <meta name="awe-page-meta" content="false">

local function html_escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

-- title of the first sidebar in _quarto.yml whose entries mention `rel`
local function sidebar_title(rel)
  local dir = quarto.project and quarto.project.directory
  if not dir or not rel then return nil end
  local f = io.open(dir .. "/_quarto.yml", "r")
  if not f then return nil end
  local title, found, in_sidebars = nil, nil, false
  for line in f:lines() do
    if line:match("^%s+sidebar:%s*$") then
      in_sidebars = true
    elseif not in_sidebars then
      -- navbar entries before the sidebars are ignored
    elseif line:match("^%s*%- id:") then
      title = nil
    else
      local t = line:match("^%s+title:%s*(.-)%s*$")
      if t and not title then
        title = t:gsub("^[\"']", ""):gsub("[\"']$", "")
      end
    end
    if title and line:find(rel, 1, true) then
      found = title
      break
    end
  end
  f:close()
  return found
end

function Meta(meta)
  if not quarto.doc.is_format("html") or quarto.doc.is_format("revealjs") then
    return nil
  end

  if meta["page-meta"] == false then
    quarto.doc.include_text("in-header", '<meta name="awe-page-meta" content="false">')
  end

  local path = quarto.doc.input_file
  if not path then return nil end

  local dir = quarto.project and quarto.project.directory
  if dir and path:sub(1, #dir + 1) == dir .. "/" then
    local title = sidebar_title(path:sub(#dir + 2))
    if title and title ~= "" then
      quarto.doc.include_text("in-header",
        '<meta name="awe-sidebar-title" content="' .. html_escape(title) .. '">')
    end
  end

  local f = io.open(path, "r")
  if not f then return nil end
  local src = f:read("a")
  f:close()

  local fm = src:match("^%-%-%-%s*\n(.-)\n%-%-%-")
  if not fm or not fm:match("revealjs") then return nil end

  -- output-file inside the revealjs block (up to the next top-level key)
  local block = fm:match("[%w%-]*revealjs:%s*\n(.-)\n%S") or fm:match("[%w%-]*revealjs:%s*\n(.*)$") or ""
  local out = block:match("output%-file:%s*[\"']?([%w%._%-/]+)") or "slides.html"

  quarto.doc.include_text("in-header",
    '<meta name="awe-slides" content="' .. out .. '">')
  return nil
end
