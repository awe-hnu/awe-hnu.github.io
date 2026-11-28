-- highlight-color.lua
-- Sets the slide highlight colour (CSS variable --awe-highlight, used by
-- lib/theme/awe-editorial.scss) from YAML metadata, overriding the default:
--
--   highlight-color: "#FF6A3D"
--
-- Works in a unit's front matter or in a course-wide _metadata.yml.
-- Only affects revealjs output; the HTML wiki is unchanged.

function Meta(meta)
  if not quarto.doc.is_format("revealjs") then
    return nil
  end

  local value = meta["highlight-color"]
  if value == nil then
    return nil
  end

  local color = pandoc.utils.stringify(value)

  -- accept hex codes, colour names, and rgb()/hsl()/oklch() values only,
  -- so the value cannot break out of the style block
  if not color:match("^[#%w%s%(%)%.,%%/-]+$") then
    quarto.log.warning("highlight-color: ignoring invalid value '" .. color .. "'")
    return nil
  end

  -- html:root outranks the theme's :root default regardless of load order
  quarto.doc.include_text(
    "in-header",
    "<style>html:root{--awe-highlight:" .. color .. ";}</style>"
  )
  return nil
end
