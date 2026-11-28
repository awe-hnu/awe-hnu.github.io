-- section-title.lua
-- Marks section dividers with an explicit class:
--
--   # Positioning {.section-title time="45"}
--
-- revealjs only: adds .headline-only to every heading with .section-title,
-- so the divider styling (both themes), the section numbers and running
-- header (lib/theme/awe-editorial.html) and the agenda (agenda.lua) treat
-- it as a section. Runs before agenda.lua. Plain .headline-only still
-- works (classic decks, Q&A and other unlisted headline slides).

function Header(h)
  if not quarto.doc.is_format("revealjs") then return nil end
  if h.classes:includes("section-title") and not h.classes:includes("headline-only") then
    h.classes:insert("headline-only")
    return h
  end
  return nil
end
