# Quarto markup conventions

## YAML front matter (per unit)

```yaml
---
title: "Unit Title"
subtitle: "Course Name"
lang: en
categories: ["Lecture Notes"]   # SPM only; omit for DL
bibliography: ../assets/literature.bib
date: "MM.DD.YYYY"
title-slide-attributes:
  data-background-image: ../assets/bg.jpg
  data-background-size: cover
  data-background-opacity: "1"
  data-background-color: '#0333ff'
format:
  html:
    output-file: index.html
    margin-header: |
      [Slides](slides.html){.btn .btn-primary target="blank"}
    format-links: false
  presentation-revealjs:
    output-file: slides.html
    include-before-body: ../assets/footer.html
---
```

## Heading hierarchy

| Level | Revealjs meaning | HTML meaning | Typical class |
|---|---|---|---|
| `#` | Section title (not a content slide) | `<h1>` section | `.headline-only`, `.html-hidden` |
| `##` | Individual slide | `<h2>` subsection | `.discussion-slide`, `.no-headline` |
| `###` | Sub-slide (rare) or hidden inside `:::notes` | `<h3>` | `{visibility=hidden}` in notes |

## Standard slide-type classes

```
# Section divider {.headline-only}
## Discussion prompt {.html-hidden .unlisted .discussion-slide}
## Featured quote {.no-headline .vertical-center background-color="#0333ff"}
## Section with scrollable content {.scrollable}
# Q&A {.html-hidden .unlisted .headline-only background-image="../assets/bg.jpg"}
## Unlabeled slide {.html-hidden .unlisted}    ← Menti or video embed
```

## Incremental reveals

Bullets one-by-one:

```markdown
:::incremental
- First point
- Second point
:::
```

Paragraph-level (SPM):

```markdown
Sentence one.

. . .

Sentence two appears after a click.
```

Inline fragmented terms:

```markdown
:::large
[Term A,]{.fragment .fade-in-then-semi-out}
[Term B,]{.fragment .fade-in-then-semi-out}
[and Term C.]{.fragment .fade-in-then-semi-out}
:::
```

Inline highlighting:

```markdown
A [specific concept]{.fragment .highlight-current-blue} explained in context.
```

Other fragment variants: `.fragment`, `.fragment .fade-in`, `.fragment .highlight-blue`.

## Text size classes

Defined in `lib/theme/awe-slides.scss`:
- `:::large`, `:::medium`, `:::small`, `:::smaller`, `:::smaller-slides`
- `{.smaller}` inline (footnote-style text within a larger block)

## Speaker notes

```markdown
:::notes
Full prose explanation. Surfaces in HTML wiki under SPM approach;
presenter-only under DL approach (see 04-dual-format.md).

Include final/complete figure version here:
![Caption [@key, p. X]](images/fig.svg){#fig-xxx}

### Sub-topic {visibility=hidden}
Sub-headings hidden from slide navigation but structure long notes.
:::
```

## Animated figure sequences (r-stack)

```markdown
::: {.r-stack .html-hidden}
![Caption](images/fig-1.svg){.fragment height="420"}
![&nbsp;](images/fig-2.svg){.fragment height="420"}
![&nbsp;](images/fig.svg){.fragment height="420"}
:::

:::notes
![Caption [@key, p. X]](images/fig.svg){#fig-xxx}
:::
```

Intermediate frames use `![&nbsp;]` as alt text. Final frame is repeated in notes with a proper `#fig-xxx` label.

## Columns

```markdown
::::columns
:::{.column width="66%"}
Left content
:::
:::{.column width="33%"}
Right content
:::
::::
```

## Callouts

Only `callout-note`. Used inside `:::notes` for supplementary material:

```markdown
:::callout-note
#### Title
Body text.
:::
```

Use `collapse=true` for optional deep-dives.

## Definition lists

```markdown
Term
: Definition text in a complete sentence.

Another term
: Its definition, potentially spanning multiple sentences.
```

## Tables

Always include caption and identifier:

```markdown
| Col A | Col B |
|---|---|
| … | … |
: Caption text {#tbl-xxx}
```

Incremental rows: add `.fragment` per row element.

## Footnotes

```markdown
Some claim in text[^1].

[^1]: Clarifying detail or full citation if needed.
```

For clarifying asides and term definitions that would break slide flow.

## Cross-references (DL pattern)

```markdown
[Unit 1](../foundations/index.qmd#section-id)
[Unit 3](../team/index.qmd#section-id)
```

## Countdown shortcode

End of every discussion slide:

```markdown
{{< countdown "10:00" top="0">}}
```

## Image naming

Animated series: `fig-1.svg`, `fig-2.svg`, …, `fig.svg` (final). Located in `images/` sub-folder of each unit directory.

## File and folder layout

```
lectures/<COURSE>/<TERM>/<unit-slug>/
    index.qmd         ← single source for both HTML and slides
    images/
        fig-1.svg
        fig.svg
lectures/<COURSE>/<TERM>/assets/
    literature.bib    ← per-course bibliography
    bg.jpg            ← title slide background
    footer.html       ← slide footer partial
```

One `index.qmd` per unit. No separate slide file; dual-output handled by the `format:` block. Solution notes, case prep, and assignment files live in their own sub-folders with separate `index.qmd` files.
