#let block-margin = .5em

#show heading: it => {
  // Set different margins based on heading level

  let top-margin = if it.level == 1 {
    block-margin * 4
  } else if it.level == 2 {
    block-margin * 3
  } else {
    block-margin * 2
  }
  
  let bottom-margin = if it.level == 1 {
    block-margin * 3
  } else if it.level == 2 {
    block-margin * 2
  } else {
    block-margin * 1.5
  }
  
  block(
    above: top-margin,
    below: bottom-margin,
    [
      #set text(weight: "regular")
      #it
    ]
  )
}

#show strong: it => [#text(weight: "regular")[#it.body]]
#show strong: it => [#underline(offset: 3pt)[#it.body]]

// Style blockquotes with a left border that matches the content height
#show quote: it => {
  pad(
    left: 2pt,
    block(
      above: block-margin,
      below: block-margin,
      stroke: (left: 1pt + 	rgb("#0333ff")),
      inset: (left: block-margin/2, top: block-margin/2, bottom: block-margin/2),  // Add vertical padding
      it
    )
  )
}