-- qa-contact.lua
-- Adds the author's name and email to the Q&A slide:
--
--   # Q&A {.html-hidden .unlisted .headline-only .bg-highlight .qa-slide}
--
-- Name and email come from the `author` metadata (set once in _quarto.yml):
--
--   author:
--     - name: "Andy Weeger"
--       email: "andy.weeger@hnu.de"
--
-- A plain string author works too (name only, no email line).
-- Turn it off per unit or course with `qa-contact: false`.
-- revealjs only: inserts a .qa-contact block right after each level-1
-- heading with .qa-slide. The HTML wiki hides the Q&A slide anyway.

local function first(value)
  if value == nil then return nil end
  if pandoc.utils.type(value) == "List" then return value[1] end
  return value
end

local function text(value)
  if value == nil then return "" end
  if type(value) == "table" and value.literal ~= nil then
    return pandoc.utils.stringify(value.literal)
  end
  return pandoc.utils.stringify(value)
end

-- returns name, email of the first author (either may be "")
local function author_contact(meta)
  local a = first(meta["author"])
  if a == nil then return "", "" end
  if type(a) == "table" and (a.name ~= nil or a.email ~= nil) then
    return text(a.name), text(a.email)
  end
  return text(a), ""
end

function Pandoc(doc)
  if not quarto.doc.is_format("revealjs") then return nil end

  local setting = doc.meta["qa-contact"]
  if setting == false or (setting ~= nil and pandoc.utils.stringify(setting) == "false") then
    return nil
  end

  local name, email = author_contact(doc.meta)
  if name == "" and email == "" then return nil end

  local lines = pandoc.List()
  if name ~= "" then
    lines:insert(pandoc.Para({ pandoc.Span(pandoc.Inlines(name), pandoc.Attr("", { "qa-contact-name" })) }))
  end
  if email ~= "" then
    lines:insert(pandoc.Para({ pandoc.Link(pandoc.Inlines(email), "mailto:" .. email, "",
      pandoc.Attr("", { "qa-contact-email" })) }))
  end

  local blocks = pandoc.List()
  local changed = false
  for _, b in ipairs(doc.blocks) do
    blocks:insert(b)
    if b.t == "Header" and b.level == 1 and b.classes:includes("qa-slide") then
      blocks:insert(pandoc.Div(lines:clone(), pandoc.Attr("", { "qa-contact" })))
      changed = true
    end
  end
  if not changed then return nil end
  doc.blocks = blocks
  return doc
end
