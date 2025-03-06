-- html-hidden-filter.lua
-- A filter to remove elements with class "html-hidden" from Pandoc output
-- Also removes entire sections when a header has html-hidden class
-- For use with Quarto documents

-- Function to check if an element has the html-hidden class
local function has_html_hidden_class(elem)
  if elem.classes then
    for _, class in ipairs(elem.classes) do
      if class == "html-hidden" then
        return true
      end
    end
  end
  return false
end

-- Track if we're in a hidden section and at what level
local hidden_section_level = 0

-- Process the document
local function process_document(doc)
  local new_blocks = {}
  
  -- Reset tracking variables at the start of processing
  hidden_section_level = 0
  
  for i, block in ipairs(doc.blocks) do
    if block.t == "Header" then
      -- When we hit a header, we need to determine if we're starting a new section
      -- or exiting a hidden section
      
      -- If new header level is <= current hidden section level, we're exiting the hidden section
      if hidden_section_level > 0 and block.level <= hidden_section_level then
        hidden_section_level = 0
      end
      
      -- Check if this header should be hidden
      if has_html_hidden_class(block) then
        hidden_section_level = block.level
        -- Don't add this header to new_blocks
      else
        -- Only add non-hidden headers that aren't in a hidden section
        if hidden_section_level == 0 then
          table.insert(new_blocks, block)
        end
      end
    else
      -- For non-header blocks, only add them if not in a hidden section
      -- and if they don't have the html-hidden class themselves
      if hidden_section_level == 0 and not has_html_hidden_class(block) then
        table.insert(new_blocks, block)
      end
    end
  end
  
  doc.blocks = new_blocks
  return doc
end

-- Process specific element types
local function filter_div(div)
  if has_html_hidden_class(div) then
    return {} -- Return an empty list to remove the element
  end
  return div
end

local function filter_span(span)
  if has_html_hidden_class(span) then
    return {} -- Return an empty list to remove the element
  end
  return span
end

local function filter_codeblock(code)
  if has_html_hidden_class(code) then
    return {} -- Return an empty list to remove the element
  end
  return code
end

local function filter_code(code)
  if has_html_hidden_class(code) then
    return {} -- Return an empty list to remove the element
  end
  return code
end

local function filter_table(tbl)
  if has_html_hidden_class(tbl) then
    return {} -- Return an empty list to remove the element
  end
  return tbl
end

local function filter_image(img)
  if has_html_hidden_class(img) then
    return {} -- Return an empty list to remove the element
  end
  return img
end

local function filter_link(link)
  if has_html_hidden_class(link) then
    return {} -- Return an empty list to remove the element
  end
  return link
end

-- Return the filter functions
return {
  Pandoc = process_document,
  Div = filter_div,
  Span = filter_span,
  CodeBlock = filter_codeblock,
  Code = filter_code,
  Table = filter_table,
  Image = filter_image,
  Link = filter_link
}