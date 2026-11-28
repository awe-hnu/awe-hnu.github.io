-- notes-headings.lua
-- Sub-headings inside speaker notes structure the HTML wiki:
--
--   :::notes
--   ### Strategy as Plan {visibility=hidden}
--   ...
--   :::
--
-- In revealjs, a heading inside a notes div ends the slide early: the notes
-- (and every block after them) land outside the slide, in the section's
-- stack, and show on every slide of that section. revealjs only: replace
-- each heading inside .notes with a bold paragraph (the HTML wiki keeps the
-- headings).

local function demote(div)
  return pandoc.walk_block(div, {
    Header = function(h)
      return pandoc.Para({ pandoc.Strong(h.content) })
    end,
  })
end

function Div(div)
  if not quarto.doc.is_format("revealjs") then return nil end
  if div.classes:includes("notes") then
    return demote(div)
  end
  return nil
end
