Para = function(e)
  if (not quarto.doc.isFormat("revealjs")) then
    if (e == pandoc.Para '. . .') then
      return {}
    end
  end
  return nil
end