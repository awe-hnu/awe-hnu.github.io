-- slide-parts.lua
-- One section in the HTML wiki, several slides in revealjs.
--
--   ## Learning Outcomes {.split .slide-parts}
--
--   ::: {.kicker .html-hidden}
--   Outcome
--   :::
--
--   After completing this course, you will be able to:
--
--   ::: {.slide-part title="Positioning"}
--   ...
--   :::
--
--   ::: {.slide-part title="Writing"}
--   ...
--   :::
--
-- Part attributes (both optional, combinable):
--   title="..."   replaces the slide heading (default: the section heading)
--   kicker="..."  replaces the lead's :::kicker on that slide (or adds one
--                 at the top if the lead has none)
--
-- revealjs: every .slide-part becomes its own slide; the heading's classes
--   (e.g. .split) carry over, and the blocks before the first part (kicker,
--   lead sentence) repeat on every slide. Slides after the first are
--   .unlisted (kept out of the slide menu).
-- Other formats (HTML wiki): one heading with the lead once; each part
--   follows with its title (or, without title, its kicker) as a bold label
--   paragraph. Mark slide-only blocks (e.g. the kicker) with .html-hidden;
--   lib/filter/html-hidden.lua removes them from the HTML output.

local function strip_class(classes, name)
  return classes:filter(function(c) return c ~= name end)
end

local function attr_inlines(part, name)
  local t = part.attributes[name]
  if t == nil or t == "" then return nil end
  local doc = pandoc.read(t, "markdown")
  if #doc.blocks > 0 and doc.blocks[1].content then
    return doc.blocks[1].content
  end
  return pandoc.Inlines(t)
end

local function label(part)
  local inl = attr_inlines(part, "title") or attr_inlines(part, "kicker")
  if not inl then return nil end
  return pandoc.Para({ pandoc.Strong(inl) })
end

local function is_kicker(blk)
  return blk.t == "Div" and blk.classes:includes("kicker")
end

-- lead blocks for one slide, with the part's kicker swapped in
local function lead_for(lead, part)
  local blocks = lead:map(function(x) return x:clone() end)
  local inl = attr_inlines(part, "kicker")
  if not inl then return blocks end
  local replaced = false
  for idx, blk in ipairs(blocks) do
    if is_kicker(blk) then
      blk.content = pandoc.Blocks({ pandoc.Para(inl) })
      blocks[idx] = blk
      replaced = true
      break
    end
  end
  if not replaced then
    blocks:insert(1, pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", { "kicker" })))
  end
  return blocks
end

function Pandoc(doc)
  local reveal = quarto.doc.is_format("revealjs")
  local blocks = doc.blocks
  local out = pandoc.List()
  local i = 1

  while i <= #blocks do
    local b = blocks[i]
    if b.t == "Header" and b.classes:includes("slide-parts") then
      -- collect the section belonging to this heading
      local section = pandoc.List()
      local j = i + 1
      while j <= #blocks and not (blocks[j].t == "Header" and blocks[j].level <= b.level) do
        section:insert(blocks[j])
        j = j + 1
      end

      local hdr = b:clone()
      hdr.classes = strip_class(hdr.classes, "slide-parts")

      -- split the section into lead blocks and parts
      local lead = pandoc.List()
      local parts = pandoc.List()
      for _, blk in ipairs(section) do
        if blk.t == "Div" and blk.classes:includes("slide-part") then
          parts:insert(blk)
        elseif #parts == 0 then
          lead:insert(blk)
        else
          parts[#parts].content:insert(blk)   -- trailing blocks join the last part
        end
      end

      if #parts == 0 then
        out:insert(hdr)
        out:extend(section)
      elseif reveal then
        for k, part in ipairs(parts) do
          local h = hdr:clone()
          local inl = attr_inlines(part, "title")
          if inl then h.content = inl end
          if k > 1 then
            if hdr.identifier ~= "" then h.identifier = hdr.identifier .. "-" .. k end
            if not h.classes:includes("unlisted") then h.classes:insert("unlisted") end
          end
          out:insert(h)
          out:extend(lead_for(lead, part))
          out:extend(part.content)
        end
      else
        out:insert(hdr)
        out:extend(lead)
        for _, part in ipairs(parts) do
          local lab = label(part)
          local content = pandoc.List()
          if lab then content:insert(lab) end
          content:extend(part.content)
          out:insert(pandoc.Div(content, pandoc.Attr("", { "slide-part" })))
        end
      end
      i = j
    else
      out:insert(b)
      i = i + 1
    end
  end

  doc.blocks = out
  return doc
end
