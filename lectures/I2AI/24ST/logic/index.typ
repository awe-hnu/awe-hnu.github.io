// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): block.with(
    fill: luma(230), 
    width: 100%, 
    inset: 8pt, 
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
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

#show figure: it => {
  if type(it.kind) != "string" {
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
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    new_title_block +
    old_callout.body.children.at(1))
}

#show ref: it => locate(loc => {
  let target = query(it.target, loc).first()
  if it.at("supplement", default: none) == none {
    it
    return
  }

  let sup = it.supplement.text.matches(regex("^45127368-afa1-446a-820f-fc64c546b2c5%(.*)")).at(0, default: none)
  if sup != none {
    let parent_id = sup.captures.first()
    let parent_figure = query(label(parent_id), loc).first()
    let parent_location = parent_figure.location()

    let counters = numbering(
      parent_figure.at("numbering"), 
      ..parent_figure.at("counter").at(parent_location))
      
    let subcounter = numbering(
      target.at("numbering"),
      ..target.at("counter").at(target.location()))
    
    // NOTE there's a nonbreaking space in the block below
    link(target.location(), [#parent_figure.at("supplement") #counters#subcounter])
  } else {
    it
  }
})

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
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
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      block(
        inset: 1pt, 
        width: 100%, 
        block(fill: white, width: 100%, inset: 8pt, body)))
}



#let article(
  title: none,
  authors: none,
  date: none,
  abstract: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: (),
  fontsize: 11pt,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)

  if title != none {
    align(center)[#block(inset: 2em)[
      #text(weight: "bold", size: 1.5em)[#title]
    ]]
  }

  if authors != none {
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

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[Abstract] #h(1em) #abstract
    ]
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
      depth: toc_depth
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}
#show: doc => article(
  title: [Propositional Logics],
  authors: (
    ( name: [Andy Weeger],
      affiliation: [Neu-Ulm University of Applied Sciences],
      email: [] ),
    ),
  date: [April 16, 2023],
  lang: "en",
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)
#import "@preview/fontawesome:0.1.0": *


= Logical agents
<logical-agents>
== Search limitations
<search-limitations>
The problem-solving agents based on #strong[search algorithms] know things, but only in a very limited, inflexible sense #cite(<RusselNorvig2022AIMA>)[, p.~226];:

#block[
- They know what actions are available \(#emph[ACTIONS\(s)];) and what the result of performing a specific action from a specific state will be \(#emph[RESULT\(s,a)];). But they #strong[don’t know general facts];.
- Using #strong[atomic representations];, representing knowledge about the environment \(i.e., the state space) requires to list all possible concrete states
- The goal can formally only be described as an #strong[explicit set of states]

]
== Rational thinking
<rational-thinking>
Until now, the focus has been on agents that act rationally. Often, however, rational action requires #strong[rational \(logical) thought] on the agent’s part.

. . .

Relevant aspects of the environment must be represented in a #strong[knowledge base] \(KB), composed of #strong[sentences] in knowledge representation language \(e.g., logic).

#block[
- Each sentence represents some assertion about the world \(#strong[semantics];)
- The sentences themselves have a causal influence on the agent’s behaviour in a way that is correlated with the contents of the sentences \(#strong[syntax];)
- Interaction with the KB through #emph[ASK] and #emph[TELL] operations \(simplified)
  - #emph[ASK];: asks the KB what action it should perform
  - #emph[TELL];: tells the knowledge base what it perceives

]
#block[
#block[
#callout(
body: 
[
- #strong[Axioms];: a sentence is taken as being given without being derived from other sentences
- #strong[Inference];: a sentence is derived from old sentence

]
, 
title: 
[
Types of sentences
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
)
]
]
== Knowledge-based agents
<knowledge-based-agents>
#figure([
#box(width: 741.0pt, image("images/knowledgeBasedAgents.svg"))
], caption: figure.caption(
position: bottom, 
[
A simplified illustration of a knowledge-based agent
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-kba>


#block[
A knowledge-based agent uses its knowledge base to

- represent its background knowledge,
- store its observations \(i.e., percepts),
- derive actions, and
- store its executed actions.

]
= The wumpus world
<the-wumpus-world>
The example is taken from #cite(<RusselNorvig2022AIMA>)

== Introduction
<introduction>
The #strong[wumpus world] is an environment in which knowledge-based agents can show their worth.

#block[
- A cave consisting of rooms connected by passageways
- Wumpus is in one room, it eats anyone who enters its room
- Some rooms contain bottomless pits
- The goal is to survive, to find a heap of gold and to leave the cave

]
== PEAS
<peas>
Let’s apply the PEAS concept to specify the task environment of the wumpus world \(though we do not use the complete specification here).

. . .

==== Performance measure
<performance-measure>
#block[
- +1,000 for finding the gold
- -1,000 for dying \(falling into a pit or being eaten by the wumpus)
- -1 for each action taken
- The game ends either when the agents dies or finds the gold

]

#horizontalrule

==== Environment
<environment>
#block[
- 4 x 4 grid with walls surrounding the grid
- The agent always starts in $[1 , 1]$
- The locations of gold and wumpus are chosen randomly \(other than $[1 , 1]$)
- Each square other than $[1 , 1]$ can be a pit, with probability .2
- There is a ladder to leave the cave in square $[1 , 1]$

]
==== Actuators
<actuators>
#block[
- Move \(#emph[Go forward];, #emph[turn right by 90°];, #emph[turn left by 90°];)
- Grab \(#emph[pick up an object in the same square];)
- Leave the cave \(#emph[only works in square] $[1 , 1]$)

]

#horizontalrule

==== Sensors
<sensors>
#block[
- In the square containing the wumpus and in the directly adjacent squares, the agent perceives a #emph[stench]
- In the squares neighboring a pit, the agent perceives a #emph[breeze]
- In the square where the gold is, the agent perceives a #emph[glitter]
- When the agent walks into a wall, it perceives a #emph[bump]

]
. . .

Percepts are represented as a 4-tuple, e.g., \
$[S t e n c h , B r e e z e , G l i t t e r , N o n e]$

#block[
The PEAS can be characterized as #emph[deterministic, discrete, static, and single-agent]

]
== A sample configuration
<a-sample-configuration>
#block[
#block[
#figure([
#box(width: 370.5pt, image("images/wumpusWorld.svg"))
], caption: figure.caption(
position: bottom, 
[
A typical wumpus world
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-wumpusWorld>


]
#block[
A typical wumpus world

#block[
- The agent is in the bottom left corner $[1 , 1]$, facing east \(rightward)
- There are three pits in the world \($[4 , 4]$,$[3 , 3]$, and $[3 , 1]$)
- Wumpus is in room $[1 , 3]$
- The gold is in room $[2 , 3]$

]
]
]
== Exploration
<exploration>
#block[
#figure([
#box(height: 400, image("images/ww-0.svg"))
], caption: figure.caption(
position: bottom, 
[
Moving in the wumpus world
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)


#figure([
#box(height: 400, image("images/ww-1.svg"))
], caption: figure.caption(
position: bottom, 
[
~
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)


#figure([
#box(height: 400, image("images/ww-2.svg"))
], caption: figure.caption(
position: bottom, 
[
~
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)


#figure([
#box(height: 400, image("images/ww-3.svg"))
], caption: figure.caption(
position: bottom, 
[
~
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)


]
#block[
#figure([
#box(width: 741.0pt, image("images/ww-1.svg"))
], caption: figure.caption(
position: bottom, 
[
Moving from \[1,1\] to \[2,1\]
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-ww-1>


- #strong[Left:] The initial situation after percept $[N o n e , N o n e , N o n e , N o n e]$
- #strong[Right:] After moving to $[2 , 1]$ and perceiving $[N o n e , B r e e z e , N o n e , N o n e]$

#figure([
#box(width: 741.0pt, image("images/ww-3.svg"))
], caption: figure.caption(
position: bottom, 
[
Moving from \[1,2\] to \[2,3\]
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-ww-3>


- #strong[Left:] After moving to $[1 , 1]$ and then $[1 , 2]$, and perceiving $[S t e n c h , N o n e , N o n e , N o n e]$
- #strong[Right:] After moving to $[2 , 2]$ and then $[2 , 3]$, and perceiving $[S t e n c h , B r e e z e , G l i t t e r , N o n e]$

]
= Propositional logic
<propositional-logic>
== Basic syntax
<basic-syntax>
#strong[Propositions] are the building blocks of propositional logic.

. . .

#strong[Atomic sentences] consist of a single proposition symbol, that can be `true` or `false`, e.g.,

. . .

- $B l o c k R e d$ — #emph[The block is red]
- $W_(1 , 3)$ — #emph[The wumpus is in] $[1 , 3]$

. . .

The logical connectives `and` $and$, `or` $or$, `not` $not$, `implies` $arrow.r.double.long$, and `if and only if` $arrow.l.r.double$ can be used to build #strong[complex sentences];.

. . .

Operator precedence: $not , and , or , arrow.r.double.long , arrow.l.r.double$ \(use brackets when necessary)

#block[
=== Logical connectives
<logical-connectives>
Logical connectives \(also called logical operators) are symbols or words used to connect two or more sentences \(of either a formal or a natural language) in a grammatically valid way, such that the value of the compound sentence produced depends only on that of the original sentences and on the meaning of the connective.

==== Conjunction \(and)
<conjunction-and>
$P and Q$

Sentence letters are called #strong[conjuncts];; the two conjuncts can be reversed and retain the original meaning.

=== Disjunction \(or)
<disjunction-or>
$P or Q$

Sentences letters are called #strong[disjuncts];; the two disjuncts can be reversed and retain the original meaning. The disjunction is always understood inclusively as an or/and; that is, P might entail, Q might entail, or both P and Q might entail.

=== Negation \(not)
<negation-not>
$not P$

A negated atomic sentence is called a #strong[negative literal];.

=== Implication
<implication>
$P arrow.r.double.long Q$

The first sentence letter is called #strong[antecedent] and second is called #strong[consequent];. The antecedent and consequent cannot be reversed and still retain its original meaning. Implications are also known as rules of if-then statements.

=== Biconditional \(if and only if, iff)
<biconditional-if-and-only-if-iff>
$P arrow.l.r.double Q$

The biconditional combines a conditional relation between P and Q and its reverse. Sentence letters are called "biconditions"; the two biconditions can be reversed and retain the original meaning.

=== Truth tables
<truth-tables>
#figure([
#figure(
align(center)[#table(
  columns: 7,
  align: (col, row) => (center,center,center,center,center,center,center,).at(col),
  inset: 6pt,
  [$alpha$], [$beta$], [$not alpha$], [$alpha and beta$], [$alpha or beta$], [$alpha arrow.r.double.long beta$], [$alpha arrow.l.r.double beta$],
  [#strong[false];],
  [#strong[false];],
  [true],
  [false],
  [false],
  [true],
  [true],
  [#strong[false];],
  [#strong[true];],
  [true],
  [false],
  [true],
  [true],
  [false],
  [#strong[true];],
  [#strong[false];],
  [false],
  [false],
  [true],
  [false],
  [false],
  [#strong[true];],
  [#strong[true];],
  [false],
  [true],
  [true],
  [true],
  [true],
)]
)

], caption: figure.caption(
position: top, 
[
Truth tables for the five logical connectives
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
numbering: "1", 
)
<tbl-ttConnectives>


]
#block[
#heading(
level: 
2
, 
outlined: 
false
, 
[
Exercise 1
]
)
]
Explain the logical operators to each other and complete following truth table.

#block[
#figure(
align(center)[#table(
  columns: 7,
  align: (col, row) => (center,center,center,center,center,center,center,).at(col),
  inset: 6pt,
  [$alpha$], [$beta$], [$not alpha$], [$alpha and beta$], [$alpha or beta$], [$alpha arrow.r.double.long beta$], [$alpha arrow.l.r.double beta$],
  [#strong[false];],
  [#strong[false];],
  [],
  [],
  [],
  [],
  [],
  [#strong[false];],
  [#strong[true];],
  [],
  [],
  [],
  [],
  [],
  [#strong[true];],
  [#strong[false];],
  [],
  [],
  [],
  [],
  [],
  [#strong[true];],
  [#strong[true];],
  [],
  [],
  [],
  [],
  [],
)]
)

]
== Basic semantics
<basic-semantics>
Atomic propositions can be `true` or `false`.

. . .

The truth of a formula follows from the truth of its atomic propositions \(#strong[truth assignment] or #strong[interpretation];) and the connectives.

. . .

Examples:

#block[
- $(P or Q) and R$
  - If P and Q are false and R is true, the formula is false
  - If P and R are true, the formula is true regardless of what Q is
- $B_(2 , 1) arrow.l.r.double (P_(2 , 2) or P_(3 , 1))$
  - A square is breezy if a neighboring square has a pit, \
    and a square is breezy only if a neighboring square has a pit

]
== A simple KB
<a-simple-kb>
==== Symbols
<symbols>
If we focus on the immutable aspects of the wumpus world, we need the following symbols for each $[x , y]$ location

#block[
- $P_(x , y)$ is true if there is a pit in $[x , y]$
- $W_(x , y)$ is true if there is a wumpus in $[x , y]$, dead or alive
- $B_(x , y)$ is true if there is a breeze in $[x , y]$
- $S_(x , y)$ is true if there is a stench in $[x , y]$
- $L_(x , y)$ is true if the agent is in location $[x , y]$

]

#horizontalrule

==== Sentences
<sentences>
#block[
#block[
#figure([
#box(width: 370.5pt, image("images/wumpusWorld-4.svg"))
], caption: figure.caption(
position: bottom, 
[
The situation reflected by the sentences
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-wumpusWorld-3>


]
#block[
Following sentences#footnote[We label each sentence $R_i$ so that we can refer to them] reflect the $K B$ for the situation depicted in @fig-wumpusWorld-3 where the agent has moved to $[2 , 1]$ and received the precepts below:

$[N o n e , B r e e z e , N o n e , N o n e]$

#block[
- $R_1 : not P_(1 , 1)$
- $R_2 : B_(1 , 1) arrow.l.r.double (P_(1 , 2) or P_(2 , 1))$
- $R_3 : B_(2 , 1) arrow.l.r.double (P_(1 , 1) or P_(2 , 2) or P_(3 , 1))$
- $R_4 : not B_(1 , 1)$
- $R_5 : B_(2 , 1)$

]
]
]
== A simple inference
<a-simple-inference>
Our goal is to decide wether $K B tack.r.double alpha$#footnote[$K B tack.r.double alpha$ means that $K B$ does entail $alpha$ \(a sentence $alpha$ follows logically from $K B$)] for some sentence $alpha$, \
e.g.~is $not P_(1 , 2)$ entailed by our $K B$ \(and, thus, a safe place to move)?

. . .

#strong[Model checking] enumerates all possible models to check that $alpha$ is true in every model in which $K B$ is true#footnote[In mathematical notation, we write $M (K B) subset.eq M (alpha)$];.

. . .

Example \(the agent has just moved to $[2 , 1]$):

#block[
- Given current proposition symbols there are 27 \= 128 possible models#footnote[7 symbols \($B_(1 , 1)$, $B_(2 , 1)$, $P_(1 , 1)$, $P_(1 , 2)$, $P_(2 , 1)$, $P_(2 , 2)$, $P_(3 , 1)$), two statuses each \(true, false); models are assignments of #emph[true] or #emph[false] to every proposition symbol]
- In three of these models $R_1$ to $R_5$ \(the current KB) are true
- In all of these three models, $P_(1 , 2)$ is false
- So we can say, there is not pit in $[1 , 2]$
- Only two of the three models, $P_(2 , 2)$ is true
- So we cannot yet tell whether there is a pit in $[2 , 2]$

]
= Propositional proofs
<propositional-proofs>
== Introduction
<introduction-1>
Entailment by the $K B$ \(or logical consequence) can also be done by #strong[theorem proving];.

. . .

#strong[Theorem proving] means applying rules of inference directly to the sentences in the knowledge base to construct a proof of the desired sentence without consulting models.

. . .

For large number of models and short length of proofs, theorem proving #strong[can be more efficient] than model checking.

== Additional concepts
<additional-concepts>
/ Logical equivalence: #block[
Two sentences $alpha$ and $beta$ are logically equivalent if they are true in the same set of models#footnote[An alternative definition of equivalence is as follows: any two sentences $alpha$ and $beta$ are equivalent if and only if each of them entails the other: $alpha equiv beta$ if and only if $alpha tack.r.double beta$ and $beta tack.r.double alpha$];, i.e. $alpha equiv beta$#footnote[Note that $equiv$ is used to make claims about sentences, while $arrow.l.r.double$ is used as part of a sentence]
]

. . .

/ Validity: #block[
A sentence is valid if it is true in #emph[all] models \(e.g., $P or not P$)#footnote[Valid sentences are also known as #strong[tautologies];, they are necessarily true]
]

. . .

/ Deduction theorem: #block[
For any sentences $alpha$ and $beta$, $alpha tack.r.double beta$ if and only if the sentence $(alpha arrow.r.double.long beta)$ is valid.#footnote[The deduction theorem states that every valid implication sentence describes a legitimate inference]
]

. . .

/ Satisfiability: #block[
A sentence is satisfiable if it is true in, or satisfied by, #emph[some] model#footnote[The knowledge database given earlier \($R_1 and R_2 and R_3 and R_4 and R_5$) is satisfiable because there are three models in which it is true.]
]

. . .

Validity and satisfiability are connected: \
$alpha tack.r.double beta$ if and only if the sentence $(alpha and not beta)$ is unsatisfiable#footnote[$alpha$ is valid iff $not alpha$ is unsatisfiable; contrapositively, $alpha$ is satisfiable iff $not alpha$ is not valid.]

== Standard logical equivalences
<standard-logical-equivalences>
#block[
#figure([
#figure(
align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [#strong[Commutativity of] $and$ #strong[and] $or$],
  [$alpha and beta equiv beta and alpha$],
  [$alpha or beta equiv beta or alpha$],
  [#strong[Associativity of] $and$ #strong[and] $or$],
  [$(alpha and beta) and gamma equiv alpha and (beta and gamma)$],
  [$(alpha or beta) or gamma equiv alpha or (beta or gamma)$],
  [#strong[Double negation elimination];],
  [$not (not alpha) equiv alpha$],
  [],
  [#strong[Contraposition];],
  [$alpha arrow.r.double.long beta equiv not beta arrow.r.double.long not alpha$],
  [],
  [#strong[Implication elimination];],
  [$alpha arrow.r.double.long beta equiv not alpha or beta$],
  [],
  [#strong[Biconditional elimination];],
  [$alpha arrow.l.r.double beta equiv (alpha arrow.r.double.long beta) and (beta arrow.r.double.long alpha)$],
  [],
  [#strong[De Morgan];],
  [$not (alpha and beta) equiv not alpha or not beta$],
  [$not (alpha or beta) equiv not alpha and not beta$],
  [#strong[Distributivity of] $and$ #strong[over] $or$ #strong[and vice versa];],
  [$alpha and (beta or gamma) equiv (alpha and beta) or (alpha and gamma)$],
  [$alpha or (beta and gamma) equiv (alpha or beta) and (alpha or gamma)$],
)]
)

], caption: figure.caption(
position: top, 
[
Logical equivalences \(the symbols $alpha$, $beta$, and $gamma$ stand for arbitrary sentences of propositional logic)
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
numbering: "1", 
)
<tbl-equiv>


]
#block[
#heading(
level: 
2
, 
outlined: 
false
, 
[
Exercise 2
]
)
]
#block[
Check the following equivalences. \
If you have issues of understanding, try to find a real life example.

]
#block[
#figure(
align(center)[#table(
  columns: 3,
  align: (col, row) => (auto,auto,auto,).at(col),
  inset: 6pt,
  [#strong[Commutativity of] $and$ #strong[and] $or$],
  [$alpha and beta equiv beta and alpha$],
  [$alpha or beta equiv beta or alpha$],
  [#strong[Associativity of] $and$ #strong[and] $or$],
  [$(alpha and beta) and gamma equiv alpha and (beta and gamma)$],
  [$(alpha or beta) or gamma equiv alpha or (beta or gamma)$],
  [#strong[Double negation elimination];],
  [$not (not alpha) equiv alpha$],
  [],
  [#strong[Contraposition];],
  [$alpha arrow.r.double.long beta equiv not beta arrow.r.double.long not alpha$],
  [],
  [#strong[Implication elimination];],
  [$alpha arrow.r.double.long beta equiv not alpha or beta$],
  [],
  [#strong[Biconditional elimination];],
  [$alpha arrow.l.r.double beta equiv (alpha arrow.r.double.long beta) and (beta arrow.r.double.long alpha)$],
  [],
  [#strong[De Morgan];],
  [$not (alpha and beta) equiv not alpha or not beta$],
  [$not (alpha or beta) equiv not alpha and not beta$],
  [#strong[Distributivity of] $and$ #strong[over] $or$ #strong[and vice versa];],
  [$alpha and (beta or gamma) equiv (alpha and beta) or (alpha and gamma)$],
  [$alpha or (beta and gamma) equiv (alpha or beta) and (alpha or gamma)$],
)]
)

]
== Inference rules
<inference-rules>
Following #strong[inference rules];#footnote[One or two statements at the upper half of the inference rule imply the statement on the lower half] can be used in any particular instances where they apply, generating sound inferences without the need for enumerating models:

#block[
- #strong[Modus Ponens];#footnote[Latin for #emph[mode that affirms];];: $frac(alpha arrow.r.double.long beta , med alpha, beta)$ \
  The sentence $beta$ can be inferred, whenever sentences of the form $alpha arrow.r.double.long beta$ and $alpha$ are given
- #strong[And-Elimination];: $frac(alpha and beta, beta)$ From a conjunction, any of the conjuncts can be inferred

]
. . .

All #strong[logical equivalences] can be used as inference rules

== Example \(wumpus world)
<example-wumpus-world>
Rules of the game:

- $R_1 : not P_(1 , 1)$
- $R_2 : B_(1 , 1) arrow.l.r.double (P_(1 , 2) or P_(2 , 1))$
- $R_3 : B_(2 , 1) arrow.l.r.double (P_(1 , 1) or P_(2 , 2) or P_(3 , 1))$

. . .

The agent is in $[1 , 1]$ and has received following precepts:

- $R_4 : not B_(1 , 1)$

. . .

#strong[Question:] is there pit in$[1 , 2]$ or $[2 , 1]$?

Using logical inference and the $K B$ containing $R_1$ to $R_4$, we prove that $not P_(1 , 2) and not P_(2 , 1)$

#horizontalrule

==== 1. Biconditional elimination to $R_2$
<biconditional-elimination-to-r_2>
#block[
- $R_2 : B_(1 , 1) arrow.l.r.double (P_(1 , 2) or P_(2 , 1))$ \
- $alpha equiv B_(1 , 1)$ \
- $beta equiv P_(1 , 2) or P_(2 , 1)$ \
- Apply $alpha arrow.l.r.double beta equiv (alpha arrow.r.double.long beta) and (beta arrow.r.double.long alpha)$

]
. . .

#strong[Inference:] $R_6 : (B_(1 , 1) arrow.r.double.long (P_(1 , 2) or P_(2 , 1))) and ((P_(1 , 2) or P_(2 , 1)) arrow.r.double.long B_(1 , 1))$

#horizontalrule

==== 2. And-Elimination to $R_6$
<and-elimination-to-r_6>
$R_7$ can be inferred from $R_6$ as follows:

#block[
- $R_6 : (B_(1 , 1) arrow.r.double.long (P_(1 , 2) or P_(2 , 1))) and ((P_(1 , 2) or P_(2 , 1)) arrow.r.double.long B_(1 , 1))$
- $alpha equiv B_(1 , 1) arrow.r.double.long (P_(1 , 2) or P_(2 , 1))$ \
- $beta equiv (P_(1 , 2) or P_(2 , 1)) arrow.r.double.long B_(1 , 1)$ \
- Apply $frac(alpha and beta, beta)$ \(#emph[And-Elimination];)

]
. . .

#strong[Inference:] $R_7 : (P_(1 , 2) or P_(2 , 1)) arrow.r.double.long B_(1 , 1)$

#horizontalrule

==== 3. Logical equivalence for contrapositives \($R_7$)
<logical-equivalence-for-contrapositives-r_7>
$R_8$ can be inferred from $R_7$ as follows:

#block[
- $R_7 : (P_(1 , 2) or P_(2 , 1)) arrow.r.double.long B_(1 , 1)$
- $alpha equiv P_(1 , 2) or P_(2 , 1)$
- $beta equiv B_(1 , 1)$
- Apply $alpha arrow.r.double.long beta equiv not beta arrow.r.double.long not alpha$

]
. . .

#strong[Inference:] $R_8 : not B_(1 , 1) arrow.r.double.long not (P_(1 , 2) or P_(2 , 1))$

#horizontalrule

==== 4. Modus Ponens with $R_8$ and the $R_4$
<modus-ponens-with-r_8-and-the-r_4>
$R_9$ can be inferred from $R_8$ and $R_4$ as follows:

#block[
- $R_8 : not B_(1 , 1) arrow.r.double.long not (P_(1 , 2) or P_(2 , 1))$
- $alpha equiv not B_(1 , 1)$
- $beta equiv not (P_(1 , 2) or P_(2 , 1))$
- Apply Modus Ponens\[^13\] $frac(alpha arrow.r.double.long beta , med alpha, beta)$ \
- As $not B_(1 , 1)$ \($R_4$) is given, $R_9$ can be inferred

]
. . .

#strong[Inference:] $R_9 : not (P_(1 , 2) or P_(2 , 1))$

#horizontalrule

==== 5. Apply De Morgan’s rule, giving the conclusion
<apply-de-morgans-rule-giving-the-conclusion>
The conclusion \($R_10$) can be inferred from $R_9$ as follows:

#block[
- $R_9 : not (P_(1 , 2) or P_(2 , 1))$
- $alpha equiv P_(1 , 2)$
- $beta equiv P_(2 , 1)$
- Apply $not (alpha or beta) equiv (not alpha and not beta)$

]
. . .

#strong[Inference:] $R_10 : not P_(1 , 2) and not P_(2 , 1)$

Neither $[1 , 2]$ nor $[2 , 1]$ contains a pit.

== Search algorithms
<search-algorithms>
Search algorithms can be used to find a sequence of steps that constitutes a proof.

. . .

The proof problem is defined as follows:

/ Initial state: #block[
The initial knowledge database
]

. . .

/ Actions: #block[
All the inference rules applied to all the sentences in the $K B$
]

. . .

/ Result: #block[
Add the inferred sentence to the knowledge base \($K B$)
]

. . .

/ Goal: #block[
A state that contains the sentence we are trying to prove
]

= Open topics
<open-topics>
#strong[Completeness] \(if the available inference rules are inadequate, the goal is not reachable)

. . .

Level of #strong[complexity] \(though propositional logic suffices to represent the wumpus world), e.g.,

. . .

- Inference rules must be set up for #strong[each square] \(expansion of the rule set)
- We need a #strong[time index] for each proposition that refer to an aspect of the world that is subject to change \(further expansion of the rule set)

. . .

#strong[Efficiency] of inference algorithms

. . .

For further information on these and other matters, please see #cite(<RusselNorvig2022AIMA>)

= Wrap-up
<wrap-up>
== Summary
<summary>
#block[
- Rational agents require #strong[knowledge of their world] to make rational decisions
- With the help of a \(knowledge) #strong[representation language];, this knowledge is represented and stored in a #strong[knowledge base] in the form of #strong[sentences]
- A representation language is defined by its #strong[syntax];#footnote[Specifies the structure of #strong[sentences];] and its #strong[semantics];#footnote[Defines the #strong[truth] of each sentence in each #strong[possible world] or #strong[model];]
- #strong[Inference] is the process of deriving new sentences from old ones
- #strong[Propositional logic] is a simple representation language consisting of propositions symbols and logical connectives
- Solutions can be found by enumerating models \(model-checking) or #strong[inference] and #strong[proofs] using inference rules#footnote[Search algorithms can be used to find solutions]
- Propositional logic does not scale to environments of unbounded size#footnote[Propositional logic lacks the expressive power to deal concisely with time, space, and universal patterns of relationships among objects.]

]
== xkcd
<xkcd>
#figure([
#box(width: 666.0pt, image("images/xkcd.png"))
], caption: figure.caption(
position: bottom, 
[
xkcd 816: Applied Math \(explanation see #link("https://www.explainxkcd.com/wiki/index.php/816:_Applied_Math")[here];)
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-xkcd>


= ✏️ Exercises
<exercises>
== I2AI\_5 E1
<i2ai_5-e1>
#block[
#block[
Suppose the agent has progressed to the point shown in @fig-ww-3 \(left part) having perceived nothing in $[1 , 1]$, a breeze in $[2 , 1]$, and a stench in $[1 , 2]$, and is now concerned with the contents of $[1 , 3]$, $[2 , 2]$, and $[3 , 1]$. Each of these can contain a pit, and at most one can contain a wumpus. Construct the set of possible worlds \(you should find 32 of them). Mark the worlds in which the KB is true and those in which each of the following sentences is true:

- $alpha_2$ \= "There is no pit in $[2 , 2]$"
- $alpha_3$ \= "There is a wumpus in $[1 , 3]$"

Hence show that $K B tack.r.double alpha_2$ and $K B tack.r.double alpha_3$

]
#block[
You can use a table like this:

#figure(
align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,auto,auto,auto,).at(col),
  inset: 6pt,
  [Model], [$K B$], [$alpha_2$], [$alpha_3$],
  [$P_(1 , 3)$],
  [],
  [true],
  [],
  [$P_(1 , 3) , P_(3 , 1) , P_(2 , 2)$],
  [],
  [],
  [],
  […],
  [],
  [],
  [],
)]
)

Propositions not listed as true on a given line are assumed false

]
]
#block[
#strong[Solution note]

To save space, the list of models is shown as a @tbl-truthtable-5e1 rather than a collection of diagrams. There are eight possible combinations of pits in the three squares, and four possibilities for the wumpus location \(including nowhere). We can see that $K B tack.r.double alpha_2$ because every line where KB is true also has $alpha_2$ true. Similarly for $alpha_3$.

#figure([
#figure(
align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,center,center,center,).at(col),
  inset: 6pt,
  [Model], [$K B$], [$alpha_2$], [$alpha_3$],
  [],
  [],
  [true],
  [],
  [$P_(1 , 3)$],
  [],
  [true],
  [],
  [$P_(2 , 2)$],
  [],
  [],
  [],
  [$P_(3 , 1)$],
  [true],
  [true],
  [],
  [$P_(1 , 3) , P_(2 , 2)$],
  [],
  [],
  [],
  [$P_(2 , 2) , P_(3 , 1)$],
  [],
  [],
  [],
  [$P_(3 , 1) , P_(1 , 3)$],
  [],
  [true],
  [],
  [$P_(1 , 3) , P_(3 , 1) , P_(2 , 2)$],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [$W_(1 , 3)$],
  [],
  [true],
  [true],
  [$W_(1 , 3) , P_(1 , 3)$],
  [],
  [true],
  [true],
  [$W_(1 , 3) , P_(2 , 2)$],
  [],
  [],
  [true],
  [$W_(1 , 3) , P_(3 , 1)$],
  [true],
  [true],
  [true],
  [$W_(1 , 3) , P_(1 , 3) , P_(2 , 2)$],
  [],
  [],
  [true],
  [$W_(1 , 3) , P_(2 , 2) , P_(3 , 1)$],
  [],
  [],
  [true],
  [$W_(1 , 3) , P_(3 , 1) , P_(1 , 3)$],
  [],
  [true],
  [true],
  [$W_(1 , 3) , P_(1 , 3) , P_(3 , 1) , P_(2 , 2)$],
  [],
  [],
  [true],
  [],
  [],
  [],
  [],
  [$W_(3 , 1)$],
  [],
  [true],
  [],
  [$W_(3 , 1) , P_(1 , 3)$],
  [],
  [true],
  [],
  [$W_(3 , 1) , P_(2 , 2)$],
  [],
  [],
  [],
  [$W_(3 , 1) , P_(3 , 1)$],
  [],
  [true],
  [],
  [$W_(3 , 1) , P_(1 , 3) , P_(2 , 2)$],
  [],
  [],
  [],
  [$W_(3 , 1) , P_(2 , 2) , P_(3 , 1)$],
  [],
  [],
  [],
  [$W_(3 , 1) , P_(3 , 1) , P_(1 , 3)$],
  [],
  [true],
  [],
  [$W_(3 , 1) , P_(1 , 3) , P_(3 , 1) , P_(2 , 2)$],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [$W_(2 , 2)$],
  [],
  [true],
  [],
  [$W_(2 , 2) , P_(1 , 3)$],
  [],
  [true],
  [],
  [$W_(2 , 2) , P_(2 , 2)$],
  [],
  [],
  [],
  [$W_(2 , 2) , P_(3 , 1)$],
  [],
  [true],
  [],
  [$W_(2 , 2) , P_(1 , 3) , P_(2 , 2)$],
  [],
  [],
  [],
  [$W_(2 , 2) , P_(2 , 2) , P_(3 , 1)$],
  [],
  [],
  [],
  [$W_(2 , 2) , P_(3 , 1) , P_(1 , 3)$],
  [],
  [true],
  [],
  [$W_(2 , 2) , P_(1 , 3) , P_(3 , 1) , P_(2 , 2)$],
  [],
  [],
  [],
)]
)

], caption: figure.caption(
position: top, 
[
A truth table constructed for I2AI\_5 E1. Propositions not listed as true on a given line are assumed false, and only true entries are shown in the table
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
numbering: "1", 
)
<tbl-truthtable-5e1>


]
== I2AI\_5 E2
<i2ai_5-e2>
Prove, or find a counterexample to, each of the following assertions, where $alpha$, $beta$, and $gamma$ represent any logical sentence:

#block[
#set enum(numbering: "a.", start: 1)
+ If $alpha tack.r.double gamma$ or $beta tack.r.double gamma$ \(or both) then $(alpha and beta) tack.r.double gamma$
+ If $(alpha and beta) tack.r.double gamma$ then $alpha tack.r.double gamma$ or $beta tack.r.double gamma$ \(or both)
+ If $alpha tack.r.double (beta or gamma)$ then $alpha tack.r.double beta$ or $alpha tack.r.double gamma$ \(or both)
]

Remember, $alpha tack.r.double beta$ means that #strong[iff] in every model in which $alpha$ is true, $beta$ is also true.

#block[
#strong[Solution note]

#block[
#set enum(numbering: "a.", start: 1)
+ If $alpha tack.r.double gamma$ or $beta tack.r.double gamma$ \(or both) then $(alpha and beta) tack.r.double gamma$ \
  True. This follows from monotonicity
]

#block[
#callout(
body: 
[
Consider $alpha equiv A$ and $beta equiv B$

- A \= #emph[It’s raining]
- B \= #emph[Someone pees on the street]
- $gamma$ \= #emph[The street is wet]

It does mean that in any situation

- where #emph[It’s raining];, #emph[The street is wet] #strong[OR] \
- where #emph[Someone pees on the street];, #emph[The street is wet]

It also means that in any situation where #emph[It’s raining] \*\* AND #emph[Someone pees on the street];, #emph[The street is wet]

]
, 
title: 
[
Andy’s real life example
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
)
]
#block[
#set enum(numbering: "a.", start: 2)
+ If $(alpha and beta) tack.r.double gamma$ then $alpha tack.r.double gamma$ or $beta tack.r.double gamma$ \(or both) \
  False. Consider $alpha equiv A , beta equiv B , gamma equiv (A and B)$
]

#figure([
#figure(
align(center)[#table(
  columns: 4,
  align: (col, row) => (auto,center,center,center,).at(col),
  inset: 6pt,
  [], [$alpha$], [$beta$], [$alpha and beta$],
  [$A , B$],
  [true],
  [true],
  [true],
  [$A , not B$],
  [true],
  [],
  [],
  [$not A , B$],
  [],
  [true],
  [],
  [$not A , not B$],
  [],
  [],
  [],
)]
)

], caption: figure.caption(
position: top, 
[
A truth table constructed for I2AI\_5 E3b. Remember: #emph[for any sentences] $alpha$ and $beta$, $alpha tack.r.double beta$ if and only if the sentence $(alpha arrow.r.double.long beta)$ is valid. Means that in any model where $alpha$ is true, $beta$ is true.
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
numbering: "1", 
)
<tbl-truthtable-5e3b>


#block[
#callout(
body: 
[
- A \= #emph[You are at the HNU]
- B \= #emph[It’s Wednesday]
- $gamma$ \= #emph[Only vegan food is available]

\(#emph[You are at the HNU] #strong[and] #emph[It’s Wednesday];) #strong[implies] that #emph[Only vegan food is available]

But it does not mean that in any situation

- where #emph[You are at the HNU];, #emph[Only vegan food is available] #strong[OR] \
- when #emph[It’s Wednesday];, #emph[Only vegan food is available]

There might be occassions

- where #emph[You are at the HNU] and normal food is available #strong[OR]
- when #emph[It’s Wednesday] and normal food is available

]
, 
title: 
[
Andy’s real life example
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
)
]
#block[
#set enum(numbering: "a.", start: 3)
+ If $alpha tack.r.double (beta or gamma)$ then $alpha tack.r.double beta$ or $alpha tack.r.double gamma$ \(or both) \
  False. Consider $beta tack.r.double A , gamma tack.r.double not A$
]

#figure([
#figure(
align(center)[#table(
  columns: 5,
  align: (col, row) => (auto,center,center,center,center,).at(col),
  inset: 6pt,
  [], [$alpha = (A or not A)$], [$beta or gamma$], [$beta$], [$gamma$],
  [$A$],
  [true],
  [true],
  [true],
  [],
  [$not A$],
  [true],
  [true],
  [],
  [true],
)]
)

], caption: figure.caption(
position: top, 
[
A truth table constructed for I2AI\_5 E3c. Remember: #emph[for any sentences] $alpha$ and $beta$, $alpha tack.r.double beta$ if and only if the sentence $(alpha arrow.r.double.long beta)$ is valid. Means that in any model where $alpha$ is true, $beta$ is true.
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
numbering: "1", 
)
<tbl-truthtable-5e3c>


]
== I2AI\_5 E3
<i2ai_5-e3>
For each English sentence, there is a corresponding logical sentence. Work out which English sentence corresponds to which propositional logic sentence, and hence determine the meaning \(in English) of each proposition symbol.

#block[
#block[
#strong[English]

- There is a Wumpus at \(0, 1)
- If the agent is at \(0, 1) and there is a Wumpus at \(0, 1), then the agent is not alive.
- The agent is at \(0, 0) and there is no Wumpus at \(0, 1)
- The agent is at \(0, 0) or \(0, 1), but not both

]
#block[
#strong[Propositional Logic]

- $(C or B) and (not C or not B)$
- $C and not D$
- $not A or not (B and D)$
- $D$

]
]
#block[
#strong[Solution note]

$A$ \= the agent is alive $B$ \= the agent is at \(0, 1) $C$ \= the agent is at \(0, 0) $D$ \= there is a Wumpus at \(0, 1).

]
= Literature
<literature>
#block[
] <refs>



#bibliography("../assets/literature.bib")

