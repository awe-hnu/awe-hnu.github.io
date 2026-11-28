-- agenda.lua
-- Builds an agenda slide automatically from the section dividers.
--
--   agenda: true                 # in YAML (front matter or _metadata.yml)
--   agenda: "Today's Session"    # same, with a custom slide title
--
--   # Conversations {.section-title time="45"}
--
-- revealjs only: inserts the agenda slide before the first heading, i.e.
-- right after the title slide. One row per section divider (level-1
-- heading with .section-title or .headline-only, not .unlisted; see
-- section-title.lua), numbered like the dividers,
-- with the section time. A level-1 heading with a `time` attribute is
-- listed too (sections without a divider slide, e.g. in case sessions). A numeric time counts as minutes ("45 min",
-- "1 h 30 min"); any other value (e.g. "1 day") is shown as written.
-- The HTML wiki is unchanged (agendas are slide-only).

local function fmt_minutes(m)
  if m < 60 then return string.format("%d min", m) end
  local h, r = math.floor(m / 60), m % 60
  if r == 0 then return string.format("%d h", h) end
  return string.format("%d h %d min", h, r)
end

local function cell(class, inlines)
  return pandoc.Span(inlines, pandoc.Attr("", { class }))
end

function Pandoc(doc)
  if not quarto.doc.is_format("revealjs") then return nil end

  local setting = doc.meta["agenda"]
  if setting == nil or setting == false then return nil end

  local title = "Agenda"
  if type(setting) ~= "boolean" then
    local s = pandoc.utils.stringify(setting)
    if s == "false" then return nil end
    if s ~= "" and s ~= "true" then title = s end
  end

  -- collect sections
  local rows = pandoc.List()
  local n, first_heading = 0, nil
  for idx, b in ipairs(doc.blocks) do
    if b.t == "Header" then first_heading = first_heading or idx end
    if b.t == "Header" and b.level == 1 then
      local listed = b.classes:includes("headline-only") or b.classes:includes("section-title")
        or b.attributes["time"] ~= nil
      if listed and not b.classes:includes("unlisted") then
        n = n + 1
        local time = b.attributes["time"] or ""
        local minutes = tonumber(time)
        local shown = time
        if minutes then
          shown = fmt_minutes(minutes)
        end
        rows:insert(pandoc.Div({ pandoc.Plain({
          cell("agenda-num", { pandoc.Str(string.format("%02d", n)) }),
          cell("agenda-title", b.content),
          cell("agenda-time", shown ~= "" and { pandoc.Str(shown) } or {}),
        }) }, pandoc.Attr("", { "agenda-item" })))
      end
    end
  end
  if n == 0 or not first_heading then return nil end

  local list = pandoc.List({ pandoc.Div(rows, pandoc.Attr("", { "agenda-list" })) })

  local slide = pandoc.List({
    pandoc.Header(2, pandoc.Inlines(title),
      pandoc.Attr("agenda", { "agenda", "unlisted", "no-kicker" })),
  })
  slide:extend(list)

  local blocks = pandoc.List()
  for idx, b in ipairs(doc.blocks) do
    if idx == first_heading then blocks:extend(slide) end
    blocks:insert(b)
  end
  doc.blocks = blocks
  return doc
end
