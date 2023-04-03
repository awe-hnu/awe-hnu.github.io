return {
  {
    Para = function (para)
      if para.content == {pandoc.Str'.', pandoc.Space, pandoc.Str'.', pandoc.Space, pandoc.Str'.'} then
        return none
      else
        return para
      end
    end,
  }
}