// Simple numbering for non-book documents
#let equation-numbering = "(1)"
#let callout-numbering = "1"
#let subfloat-numbering(n-super, subfloat-idx) = {
  numbering("1a", n-super, subfloat-idx)
}

// Theorem configuration for theorion
// Simple numbering for non-book documents (no heading inheritance)
#let theorem-inherited-levels = 0

// Theorem numbering format (can be overridden by extensions for appendix support)
// This function returns the numbering pattern to use
#let theorem-numbering(loc) = "1.1"

// Default theorem render function
#let theorem-render(prefix: none, title: "", full-title: auto, body) = {
  if full-title != "" and full-title != auto and full-title != none {
    strong[#full-title.]
    h(0.5em)
  }
  body
}
// Some definitions presupposed by pandoc's typst output.
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let fields = old_block.fields()
  let _ = fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => {
          let subfloat-idx = quartosubfloatcounter.get().first() + 1
          subfloat-numbering(n-super, subfloat-idx)
        })
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => block({
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          })

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let children = old_title_block.body.body.children
  let old_title = if children.len() == 1 {
    children.at(0)  // no icon: title at index 0
  } else {
    children.at(1)  // with icon: title at index 1
  }

  // TODO use custom separator if available
  // Use the figure's counter display which handles chapter-based numbering
  // (when numbering is a function that includes the heading counter)
  let callout_num = it.counter.display(it.numbering)
  let new_title = if empty(old_title) {
    [#kind #callout_num]
  } else {
    [#kind #callout_num: #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block,
    block_with_new_content(
      old_title_block.body,
      if children.len() == 1 {
        new_title  // no icon: just the title
      } else {
        children.at(0) + new_title  // with icon: preserve icon block + new title
      }))

  align(left, block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1)))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color,
        width: 100%,
        inset: 8pt)[#if icon != none [#text(icon_color, weight: 900)[#icon] ]#title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}




#let article(
  title: none,
  subtitle: none,
  authors: none,
  keywords: (),
  date: none,
  abstract-title: none,
  abstract: none,
  thanks: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: none,
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: none,
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  mathfont: none,
  codefont: none,
  linestretch: 1,
  sectionnumbering: none,
  linkcolor: none,
  citecolor: none,
  filecolor: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  // Set document metadata for PDF accessibility
  set document(title: title, keywords: keywords)
  set document(
    author: authors.map(author => content-to-string(author.name)).join(", ", last: " & "),
  ) if authors != none and authors != ()
  set par(
    justify: true,
    leading: linestretch * 0.65em
  )
  set text(lang: lang,
           region: region,
           size: fontsize)
  set text(font: font) if font != none
  show math.equation: set text(font: mathfont) if mathfont != none
  show raw: set text(font: codefont) if codefont != none

  set heading(numbering: sectionnumbering)

  show link: set text(fill: rgb(content-to-string(linkcolor))) if linkcolor != none
  show ref: set text(fill: rgb(content-to-string(citecolor))) if citecolor != none
  show link: this => {
    if filecolor != none and type(this.dest) == label {
      text(this, fill: rgb(content-to-string(filecolor)))
    } else {
      text(this)
    }
   }

  let has-title-block = title != none or (authors != none and authors != ()) or date != none or abstract != none
  if has-title-block {
    place(
      top,
      float: true,
      scope: "parent",
      clearance: 4mm,
      block(below: 1em, width: 100%)[

        #if title != none {
          align(center, block(inset: 2em)[
            #set par(leading: heading-line-height) if heading-line-height != none
            #set text(font: heading-family) if heading-family != none
            #set text(weight: heading-weight)
            #set text(style: heading-style) if heading-style != "normal"
            #set text(fill: heading-color) if heading-color != black

            #text(size: title-size)[#title #if thanks != none {
              footnote(thanks, numbering: "*")
              counter(footnote).update(n => n - 1)
            }]
            #(if subtitle != none {
              parbreak()
              text(size: subtitle-size)[#subtitle]
            })
          ])
        }

        #if authors != none and authors != () {
          let count = authors.len()
          let ncols = calc.min(count, 3)
          grid(
            columns: (1fr,) * ncols,
            row-gutter: 1.5em,
            ..authors.map(author =>
                align(center)[
                  #author.name \
                  #author.affiliation \
                  #author.email
                ]
            )
          )
        }

        #if date != none {
          align(center)[#block(inset: 1em)[
            #date
          ]]
        }

        #if abstract != none {
          block(inset: 2em)[
          #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
          ]
        }
      ]
    )
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  doc
}

#set table(
  inset: 6pt,
  stroke: none
)
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
#let brand-color = (:)
#let brand-color-background = (:)
#let brand-logo = (:)

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
  columns: 1,
)

#show: doc => article(
  title: [Engaging leadership],
  subtitle: [What kind of leadership behaviors can promote work engagement?],
  authors: (
    ( name: [Andy Weeger],
      affiliation: [],
      email: [] ),
    ),
  date: [February 14, 2024],
  lang: "en",
  font: ("Basier Square",),
  fontsize: 10pt,
  heading-family: ("Basier Square",),
  toc_title: [Table of contents],
  toc_depth: 3,
  doc,
)

= Introduction
<introduction>
#quote(block: true)[
One of the principal responsibilities of leaders is to motivate their followers so that they will perform well. #emph[#cite(<schaufeli2021engaging>, form: "prose")]
]

= Work engagement
<work-engagement>
== Definition
<definition>
Work engagement refers to "a positive, fulfilling, work related state of mind that is characterized by #emph[vigor], #emph[dedication], and #emph[absorption]" @schaufeli2002measurement[p.~74]

#block[
- #strong[Vigor] refers to high levels of energy and mental resilience while working, the willingness to invest effort in one's work, and persistence even in the face of difficulties
- #strong[Dedication] refers to being strongly involved in one's work, and experiencing a sense of significance, enthusiasm, inspiration, pride, and challenge
- #strong[Absorption] refers to being fully concentrated and happily engrossed in one's work, whereby time passes quickly and one has difficulties with detaching oneself from work

]
Work engagement differs from #strong[work addiction]. Workaholics are driven by an irresistible inner need to work, and when they don't, they feel useless, nervous, uneasy, restless and guilty.

#block[
#cite(<taris2014beauty>, form: "prose") argue that engaged employees have a positive (approach) motivation and workaholics a negative (avoidance) motivation. The former are attracted by work because it is fun, whereas the latter are driven to work in an attempt to avoid the negative thoughts and feelings that are associated with not working.

]
== Effects
<effects>
Research shows that work engagement is good for employees as well as for the organizations they work for @schaufeli2013engagement.

#block[
- Engaged employees #strong[suffer less from all kinds of stress complaints] (e.g., depression)
- They run a #strong[lower risk of cardiovascular disease] and, hence, their show #strong[lower sickness absenteeism].
- Engaged employees also feel strongly committed to their organization and therefore show #strong[lower turnover intentions].
- They often show a #strong[growth mindset] (e.g., like to learn and develop themselves, take personal initiative, and are innovative).
- Engaged employees #strong[perform better] (e.g., make fewer mistakes).

]
= Engaging leadership
<engaging-leadership>
#block[
#quote(block: true)[
Engaging leadership is not another leadership concept #emph[#cite(<schaufeli2021engaging>, form: "prose")]
]

]
#block[
Instead of starting with leadership behavior and then examining its impact on employee motivation and performance, #cite(<schaufeli2021engaging>, form: "prose") started with work engagement, asking: What kind of leadership behavior can promote employee work engagement?

]
== Definition
<definition-1>
#strong[Engaging leadership] is defined as leadership behavior that facilitates, strengthens, connects and inspires employees in order to increase their work engagement @schaufeli2021engaging[p.~4]

#block[
- #strong[Facilitating] team-members satisfies the need for #emph[autonomy] by giving them the feeling that they are psychologically free to make their own decisions.
- #strong[Strengthening] team-members satisfies the need for #emph[competence], e.g., by delegating tasks and responsibilities, giving them challenging jobs and stimulating their talents.
- #strong[Connecting] team-members satisfies the need for #emph[relatedness], e.g., by encouraging collaboration and creating a good team spirit.
- #strong[Inspiring] team-members satisfies the need for #emph[meaning], e.g., by enthusing them about a particular vision, mission, idea or plan and recognising their personal contribution to the overall goal of the team or organisation.

]
== Efects
<efects>
#strong[Engaging leadership] is expected to lead to the satisfaction of #strong[basic psychological needs] (e.g., autonomy, competence, relatedness, meaning) and improved #strong[work engagement] and #strong[performance].

Satisfying basic psychological needs subsequently leads to

#block[
- strengthened personal #strong[job resources] (e.g., autonomy, task variety, role clarity, social support),
- an increased effect of HR policies (e.g., regarding training and education) on well-being,
- an increase in #strong[work engagement] of employees,
- decrease of #strong[boredom], and
- increase in #strong[individual performance] and #strong[team performance].

]
== Team effectiveness
<team-effectiveness>
Engaging leadership positively effects performance at the individual and team level @schaufeli2021engaging, thus increases #strong[team effectiveness].

According to #cite(<hill2003becoming>, form: "prose"), an effective team does not only involve #strong[team performance], but is characterized by three criteria:

#block[
+ The team #emph[performs]: the output meets the standards of those who have to use it
+ The team members are #emph[satisfied and learn] (i.e., the team experience contributes to each member's personal well-being and development)
+ The team #emph[adapts and learns] (i.e., the team experience enhances the capability of members to work and learn together in the future)

]
In today's dynamic environment, #strong[engaging leadership] should facilitate, strengthen, connect and inspire employees to improve on all three interrelated criteria.

== Managing paradox
<managing-paradox>
Committed leaders need to be aware of at least four contradictory forces in team work and deal with these paradoxes @hill2003becoming:

#block[
- Embrace individual differences ⭤ Embrace collective identity and goals
- Foster support ⭤ Foster confrontation
- Focus on performance ⭤ Focus on learning and development
- Rely on managerial authority ⭤ Rely on team members' discretion and autonomy

]
Consequently, engaging leadership requires #strong[behavioral complexity].

== Disengaging leadership
<disengaging-leadership>
According to #cite(<schaufeli2021engaging>, form: "prose"), engaging leadership can be contrasted with its opposite #strong[disengaging leadership].

Disengaging leadership is characterized by:

#block[
- #strong[Coercive behaviour], which refers to authoritarian behaviour that restricts and controls employees.
- #strong[Eroding behaviour] that aims to hinder staff members' professional development and diminish their sense of competence
- #strong[Isolating behaviour] that disconnects staff from the rest of the team and pits them against each other
- #strong[Demotivating behaviour] that aims to create the impression that employees' work is meaningless and that their work does not contribute to anything important.

]
People that exhibit these behaviors thwart the basic needs for autonomy, competence, relatedness, and meaning.

= Literature
<literature>
#block[
] <refs>



#set bibliography(style: "\../../../../lib/csl/apa.csl")

#bibliography(("../assets/literature.bib"))

