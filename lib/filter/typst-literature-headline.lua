-- literature-filter.lua
-- A Lua filter for Quarto that processes "Literature" headlines in the document body

-- This function processes Header elements (headlines)
function Header(el)
  -- Convert the header content to a string to check for "Literature"
  local content_str = pandoc.utils.stringify(el)
  
  -- Check if this header contains exactly "Literature"
  if content_str == "Literature" then
    return nil -- Return nil to remove the element, not {}
  end
  -- If this header doesn't contain "Literature", return it unchanged
  return el
end

-- This function processes the entire document and can be used for more complex operations
function Pandoc(doc)
  -- We could add document-wide processing here if needed
  return doc
end

-- Return a list of functions to apply
return {
  Header = Header,
  Pandoc = Pandoc
}