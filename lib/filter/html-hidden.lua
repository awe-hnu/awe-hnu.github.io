-- html-hidden-filter.lua
-- A filter to remove elements with class "html-hidden" from Pandoc output
-- Also removes entire sections when a header has html-hidden class
-- For use with Quarto documents

-- Function to check if an element has the html-hidden class
local function has_html_hidden_class(elem)
  if elem.classes then
    for i, class in ipairs(elem.classes) do
      if class == "html-hidden" then
        return true
      end
    end
  end
  return false
end

-- Track hidden headers to know which sections to exclude
local hidden_headers = {}

-- Pre-process to identify hidden headers
function preprocess_hidden_headers(doc)
  local headers_to_hide = {}
  
  -- First pass: identify all headers with html-hidden class
  for i, el in ipairs(doc.blocks) do
    if el.t == "Header" and has_html_hidden_class(el) then
      table.insert(headers_to_hide, {id = el.identifier, level = el.level})
    end
  end
  
  return headers_to_hide
end

-- Check if a block is part of a hidden section
local function is_in_hidden_section(header_stack, block)
  for _, hidden_header in ipairs(hidden_headers) do
    for _, current_header in ipairs(header_stack) do
      if current_header.id == hidden_header.id then
        return true
      end
    end
  end
  return false
end

-- Process the document to remove hidden sections
function process_document(doc)
  -- Get all hidden headers first
  hidden_headers = preprocess_hidden_headers(doc)
  
  local new_blocks = {}
  local header_stack = {}
  
  for i, block in ipairs(doc.blocks) do
    -- Update header stack when encountering headers
    if block.t == "Header" then
      -- Pop headers of same or higher level from stack
      while #header_stack > 0 and header_stack[#header_stack].level >= block.level do
        table.remove(header_stack)
      end
      
      -- Add current header to stack if not hidden
      if not has_html_hidden_class(block) then
        table.insert(header_stack, {id = block.identifier, level = block.level})
        table.insert(new_blocks, block)
      end
      -- If header is hidden, don't add it (and subsequent content will be filtered)
    else
      -- For non-header blocks, check if it has html-hidden class or is in a hidden section
      if not has_html_hidden_class(block) and not is_in_hidden_section(header_stack, block) then
        table.insert(new_blocks, block)
      end
    end
  end
  
  doc.blocks = new_blocks
  return doc
end

-- Process specific element types
function Div(div)
  if has_html_hidden_class(div) then
    return {} -- Return an empty list to remove the element
  end
  return div
end

function Span(span)
  if has_html_hidden_class(span) then
    return {} -- Return an empty list to remove the element
  end
  return span
end

function CodeBlock(code)
  if has_html_hidden_class(code) then
    return {} -- Return an empty list to remove the element
  end
  return code
end

function Code(code)
  if has_html_hidden_class(code) then
    return {} -- Return an empty list to remove the element
  end
  return code
end

function Table(table)
  if has_html_hidden_class(table) then
    return {} -- Return an empty list to remove the element
  end
  return table
end

function Image(image)
  if has_html_hidden_class(image) then
    return {} -- Return an empty list to remove the element
  end
  return image
end

function Link(link)
  if has_html_hidden_class(link) then
    return {} -- Return an empty list to remove the element
  end
  return link
end

-- Return the filter functions
return {
  Pandoc = process_document,
  Div = Div,
  Span = Span,
  CodeBlock = CodeBlock,
  Code = Code,
  Table = Table,
  Image = Image,
  Link = Link
}