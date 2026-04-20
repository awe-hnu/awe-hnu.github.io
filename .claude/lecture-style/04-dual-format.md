# Dual-format strategy

Each unit renders into two outputs from a single `.qmd`:
- `index.html`: wiki-style HTML for students to read after class.
- `slides.html`: revealjs presentation for in-class use.

## SPM/25WT: notes-primary approach (default)

Write shared prose. Gate slide-visible content with `:::html-hidden`. Carry the expanded HTML narrative inside `:::notes`. The `:::notes` content surfaces in the HTML output and is the primary reading experience.

```qmd
## What is value-based strategy?

:::html-hidden
:::medium
A value-based strategy focuses on **creating and capturing value** through
[willingness to pay]{.fragment .highlight-current-blue},
[pricing strategy]{.fragment .highlight-current-blue},
[cost management]{.fragment .highlight-current-blue}, and
[willingness to sell]{.fragment .highlight-current-blue}.
:::
:::

:::notes
According to the value-based strategy framework, organizations should focus on
four key questions:

- To what extent do customers demonstrate willingness to pay for the offerings?
- What pricing strategy does the company employ versus competitors?
...

The framework emphasizes that successful companies create value for customers,
employees, and suppliers while capturing value from operations.
:::
```

Sub-headings inside `:::notes` use `{visibility=hidden}`:

```markdown
### Prescriptive schools {visibility=hidden}
### Descriptive schools {visibility=hidden}
```

## DL/26ST: content-visible gating approach (fallback)

Explicitly gate per format using `:::{.content-visible when-format="revealjs"}` and `:::{.content-visible unless-format="revealjs"}`.

```qmd
## Great Man Theory (1840s)

:::medium
Great leaders **are born,** not made.
:::

:::fragment
@carlyle1841heroes argued history is shaped by exceptional individuals with innate heroic qualities.
:::

:::{.content-visible unless-format="revealjs"}
The Great Man Theory reflects the 19th-century belief that leadership capacity
is inherent. While largely discredited, it planted the seed for trait-based
research: if great leaders are "different," what makes them different?
:::

:::{.content-visible when-format="revealjs"}
:::notes
The Great Man Theory reflects the 19th-century belief that leadership capacity
is inherent. While largely discredited, it planted the seed for trait research.
:::
:::
```

Structural slide-only blocks (agendas, warm-ups, latticework check-ins) wrap in `:::{.content-visible when-format="revealjs"}` so they are absent from HTML.

## Decision rule

**Default to SPM.** Write a single shared body that reads well in both formats; use `:::notes` to carry HTML-visible narration.

**Fall back to DL gating only when content is genuinely format-specific.**

| Content type | Approach |
|---|---|
| Condensed bullet/fragment version of dense prose | `:::html-hidden` block + `:::notes` prose |
| Speaker cues, facilitation, timing notes | `:::notes` (SPM) or `:::{.content-visible when-format="revealjs"}:::notes` (DL) |
| Agenda slide, timing breakdown | `:::{.content-visible when-format="revealjs"}` |
| Warm-up, latticework check-in | `:::{.content-visible when-format="revealjs"}` |
| Discussion / exercise prompt | `## Exercise {.html-hidden .unlisted .discussion-slide}` |
| Poll/voting embed (Menti) | `## {.html-hidden .unlisted background-iframe="..."}` |
| Extended background reading | `:::{.content-visible unless-format="revealjs"}` |
| Full-slide image build (r-stack) | `r-stack` in `:::html-hidden`, final figure repeated in `:::notes` |
