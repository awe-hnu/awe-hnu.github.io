-- slide-theme.lua
-- Selects the slide theme from YAML metadata:
--
--   slide-theme: editorial   # default (lib/theme/awe-editorial.scss)
--   slide-theme: classic     # original look (lib/theme/awe-slides.scss only)
--
-- Both themes are compiled into the same stylesheet and are independent of
-- each other: awe-slides.scss applies only to `html.awe-classic`, and
-- awe-editorial.scss (with its own base layer) only to
-- `html:not(.awe-classic)`. For classic decks this filter adds the class
-- .awe-classic to <html> before the page renders.
-- Works in a unit's front matter or in a course-wide _metadata.yml.
-- Only affects revealjs output; the HTML wiki is unchanged.

function Meta(meta)
  if not quarto.doc.is_format("revealjs") then
    return nil
  end

  local value = meta["slide-theme"]
  if value == nil then
    return nil
  end

  local theme = pandoc.utils.stringify(value):lower()

  if theme == "classic" then
    quarto.doc.include_text(
      "in-header",
      "<script>document.documentElement.classList.add('awe-classic');</script>"
    )
  elseif theme ~= "editorial" then
    quarto.log.warning("slide-theme: unknown value '" .. theme ..
      "' (use 'editorial' or 'classic'); using editorial")
  end
  return nil
end
