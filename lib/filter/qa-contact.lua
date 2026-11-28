-- qa-contact.lua
-- Lays out the Q&A slide like the title slide:
--
--   # Q&A {.html-hidden .unlisted .headline-only .bg-highlight .qa-slide}
--
-- Adds the deck's `subtitle` (course name) as a label (.qa-subtitle, shown
-- above the headline) and the author's name and email on one line
-- (.qa-contact, below it). Name and email come from `author` (set once in
-- _quarto.yml):
--
--   author:
--     - name: "Andy Weeger"
--       email: "andy.weeger@hnu.de"
--
-- A plain string author works too (name only). Turn the additions off per
-- unit or course with `qa-contact: false`.
-- revealjs only: inserts the blocks right after each level-1 heading with
-- .qa-slide (awe-editorial.scss moves the subtitle on top). The HTML wiki
-- hides the Q&A slide anyway.

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

local function contact_of(a)
  if a == nil then return "", "" end
  if type(a) == "table" and (a.name ~= nil or a.email ~= nil) then
    return text(a.name), text(a.email)
  end
  return text(a), ""
end

-- returns name, email of the first author (either may be "").
-- Quarto normalizes `author` before filters run: the email lives in
-- `by-author` / `authors` (name as {literal = ...}), while `author` may
-- keep the name only. Take the first source that has an email.
local function author_contact(meta)
  local name = ""
  for _, key in ipairs({ "by-author", "authors", "author" }) do
    local n, e = contact_of(first(meta[key]))
    if name == "" then name = n end
    if e ~= "" then return (n ~= "" and n or name), e end
  end
  return name, ""
end

function Pandoc(doc)
  if not quarto.doc.is_format("revealjs") then return nil end

  local setting = doc.meta["qa-contact"]
  if setting == false or (setting ~= nil and pandoc.utils.stringify(setting) == "false") then
    return nil
  end

  local extra = pandoc.List()

  -- subtitle (course name), keeps its inline markup
  local subtitle = doc.meta["subtitle"]
  if subtitle ~= nil and pandoc.utils.stringify(subtitle) ~= "" then
    local inlines = pandoc.utils.type(subtitle) == "Inlines" and subtitle
      or pandoc.Inlines(pandoc.utils.stringify(subtitle))
    extra:insert(pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", { "qa-subtitle" })))
  end

  -- one line: name and email (gap set in awe-editorial.scss)
  local name, email = author_contact(doc.meta)
  local inlines = pandoc.List()
  if name ~= "" then
    inlines:insert(pandoc.Span(pandoc.Inlines(name), pandoc.Attr("", { "qa-contact-name" })))
  end
  if email ~= "" then
    if name ~= "" then inlines:insert(pandoc.Space()) end
    inlines:insert(pandoc.Link(pandoc.Inlines(email), "mailto:" .. email, "",
      pandoc.Attr("", { "qa-contact-email" })))
  end
  if #inlines > 0 then
    extra:insert(pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", { "qa-contact" })))
  end

  if #extra == 0 then return nil end

  local blocks = pandoc.List()
  local changed = false
  for _, b in ipairs(doc.blocks) do
    blocks:insert(b)
    if b.t == "Header" and b.level == 1 and b.classes:includes("qa-slide") then
      blocks:extend(extra:clone())
      changed = true
    end
  end
  if not changed then return nil end
  doc.blocks = blocks
  return doc
end
