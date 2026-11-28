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
  class: "quarto-title-block bg-highlight"
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

## Slide theme

Two independent slide themes are compiled into one stylesheet (set in `_quarto.yml`): `lib/theme/awe-editorial.scss` is self-contained and applies to editorial decks; `lib/theme/awe-slides.scss` applies only to classic decks (`html.awe-classic`). Either file works without the other:

| YAML key | Values | Effect |
|---|---|---|
| `slide-theme` | `editorial` (default), `classic` | `classic` restores the original look; existing decks carry `slide-theme: classic` |
| `highlight-color` | hex code, e.g. `"#16CAF7"` (default cyan) | Highlight colour of the editorial theme |

Set the keys in a unit's front matter or course-wide in a `_metadata.yml`. New decks use the editorial theme; omit `slide-theme`.

## Website Template

The HTML wiki uses `lib/theme/awe-web.scss` and `lib/theme/awe-web.html` (set in `_quarto.yml`). Each page shows an author bar (author, created, updated, categories) and an action row (Slides and Print slides when the page has a revealjs format, Copy link, and every extra `margin-header` link as a button). `page-meta: false` in the front matter hides both, e.g., on the start page.

## Agenda Slide

`agenda: true` (or `agenda: "Today's Session"` for a custom title) adds an agenda slide after the title slide, in revealjs only. It lists every section divider (`.section-title`, or `.headline-only` in classic decks; not `.unlisted`) with its number and time; set the time as a heading attribute in minutes. A level-1 heading with a `time` attribute is listed too (sections without a divider slide, e.g., case sessions). Non-numeric values (e.g., `time="1 day"`) appear as written and are excluded from the total.

```markdown
# Conversations {.section-title time="45"}
```

## Heading hierarchy

| Level | Revealjs meaning | HTML meaning | Typical class |
|---|---|---|---|
| `#` | Section title (not a content slide) | `<h1>` section | `.section-title` (classic decks: `.headline-only`), `.html-hidden` |
| `##` | Individual slide | `<h2>` subsection | `.discussion-slide`, `.no-headline` |
| `###` | Sub-slide (rare) or hidden inside `:::notes` | `<h3>` | `{visibility=hidden}` in notes |

## Standard slide-type classes

```
# Section divider {.section-title}     ← editorial decks; classic decks use .headline-only
## Discussion prompt {.html-hidden .unlisted .discussion-slide}
## Featured quote {.no-headline .vertically-centered .bg-highlight}   ← new decks; old content uses .vertical-center (same effect)
## Section with scrollable content {.scrollable}
# Q&A {.html-hidden .unlisted .headline-only background-image="../assets/bg.jpg"}
## Unlabeled slide {.html-hidden .unlisted}    ← Menti or video embed
```

## One Section, Several Slides

Use `.slide-parts` when content should read as one section in the HTML wiki but run over several slides (e.g., learning outcomes). Each `.slide-part` becomes a slide; the heading's classes carry over, and the blocks before the first part repeat on every slide. Mark slide-only blocks with `.html-hidden`.

Per part, `title="..."` replaces the slide heading (default: the section heading) and `kicker="..."` replaces the lead's `:::kicker` on that slide (or adds one). In the HTML wiki, the title (or else the kicker) appears as a bold label above the part.

```markdown
## Learning Outcomes {.split .slide-parts}

::: {.kicker .html-hidden}
Outcome
:::

After completing this course, you will be able to:

::: {.slide-part title="Positioning"}
...
:::

::: {.slide-part title="Writing"}
...
:::
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

Defined in both themes (`lib/theme/awe-slides.scss` for classic decks, the base layer of `lib/theme/awe-editorial.scss` for editorial decks):
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

## Punctuation Guidelines

- **Punctuation Inside Bold Tags:** When bolding text that immediately precedes punctuation, always place the punctuation mark *inside* the bold delimiters.
    - Correct: `**key concept:**` or `**complete sentence.**`
    - Incorrect: `**key concept**:` or `**complete sentence**.`
- Applies to all trailing punctuation attached to bolded words (periods, commas, colons, semicolons, question marks, and exclamation points).