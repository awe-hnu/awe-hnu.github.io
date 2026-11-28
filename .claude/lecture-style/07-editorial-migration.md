# Editorial Migration

Checklist for switching a course from the classic slide theme to the editorial theme. Work through it per unit (`index.qmd`), then run the checks at the end. Reference implementation: `lectures/APW/26WT` and `lectures/SPM/26WT`; component demo: `theme-demo/index.qmd`.

## 1. Front Matter

1. Remove `slide-theme: classic` (unit front matter or the course's `_metadata.yml`). The editorial theme is the default.
2. Remove the title-slide background image; keep the class:

   ```yaml
   title-slide-attributes:
     class: "quarto-title-block bg-highlight"
   ```

   Delete `data-background-image`, `data-background-size`, and `data-background-opacity`.
   In the body, replace the decorative `background-image="../assets/bg.jpg"` (Q&A and similar slides) with `.bg-highlight`:

   ```markdown
   # Q&A {.html-hidden .unlisted .headline-only .bg-highlight}
   ```

   Also remove decorative `background-image` attributes from section dividers. Keep background images that carry content (figures, photos).
3. Add `agenda: true` (or `agenda: "Today's Session"`) to units that are taught as one session.
4. Optional: `highlight-color: "#hex"` per unit or course (default cyan `#16CAF7`).

## 2. Sections and Agenda

No `#` heading that is not a `.section-title`, except `# Q&A` and `# Literature`. Every other level-1 heading becomes a `##` slide inside a section (demote its sub-headings by one level as well); add missing sections:

| Content | Section |
|---|---|
| Recap, reflection warm-up, learning objectives/outcomes, motivation | `# Introductory Remarks {.section-title}` |
| Key takeaways, review and consolidation, homework | `# Closing {.section-title}` |
| A level-1 hook slide (`# Motivation {.vertical-center .bg-highlight .no-headline}`, `# Prologue`) and the slides after it | `# Introductory Remarks {.section-title}`; demote only the hook heading, its following `##` slides stay |
| Challenges, reading list | `# Closing {.section-title}` (demote only these headings) |
| Level-1 content slides (e.g., case sessions, admin topics) | Group related topics under a descriptive section (e.g., "Strategy Analysis", "Organization"); a single topic becomes `# Topic {.section-title}` with `## Overview` |

`# Q&A` follows Closing; `# Literature` (with the `{#refs}` div directly beneath) stays the last level-1 heading. Both carry a class for their own styling:

```markdown
# Q&A {.html-hidden .unlisted .headline-only .bg-highlight .qa-slide}
# Literature {.literature-slide}
```

1. Mark section dividers with `.section-title` instead of `.headline-only`:

   ```markdown
   # Positioning {.section-title time="45"}
   ```

   Keep `.headline-only` on unlisted headline slides (`# Q&A {.html-hidden .unlisted .headline-only …}`).
2. Give every section a `time` attribute in minutes. Sum the activities of the old manual agenda per section; recap, wrap-up, and break items have no section and drop out (a `# Break {.section-title}` divider is listed without a time).
3. Without a manual agenda or given times, estimate each section's time: about 2.5 minutes per content slide plus the countdown of every exercise in the section, rounded to 5 minutes. Tell the author the times are estimates.
4. Sections without a divider slide (level-1 content slides, e.g., case sessions) appear in the agenda when they carry a `time` attribute; estimate their time the same way.
5. Delete manual agenda slides: `:::{.content-visible when-format="revealjs"}` blocks with `# Agenda` (watch for extra blank lines before the closing `:::`), `## Agenda {.unlisted …}` slides inside the opening section, and "Roadmap" or "Today's Session" slides.

## 3. Slide Classes

| Classic | Editorial | Note |
|---|---|---|
| `background-color="#0333ff"` | `.bg-highlight` | Slides with any other inline `background-color` get no running header. |
| `.vertical-center` | `.vertically-centered` | Alias; old class still works. |
| `## Exercise {… background-color=black}` (also Discussion, Reflection) | `## Exercise {… .discussion-slide}` | Dark discussion style with running header and countdown colours; keep `background-color=black` only for video slides. |
| `[X]{.fragment .highlight-current-blue}` | `[X]{.fragment .highlight-current}` | Marker on the current fragment. |
| `[X]{.fragment .highlight-blue}` | `[X]{.fragment .highlight}` | Plain until reached, then marker and bold; stays marked. |
| `[X]{.link-color}` | `[X]{.highlight-color}` | Text in the highlight colour; `.link-color` still works. |
| `[X]{.highlight}` outside animations | `**X**` | Punctuation moves inside the bold. Keep `.highlight` when the span sits inside a fragment span. |
| Learning outcomes as several `##` slides | `## Learning Outcomes {.split .slide-parts}` | One section in HTML, one slide per `.slide-part`; `title`/`kicker` per part. |
| Three key figures in columns | `:::stats` with `:::stat` | First paragraph is the figure (short: about 9 characters per column at three columns). |

`.highlight` renders as bold with a grey marker; plain bold has no marker.

**Sentence builds:** a statement that reveals its key terms one by one builds the sentence step by step; the subject stays visible, each fragment carries the text up to and including the next term, and the terms are static `.highlight` spans inside the fragments. Citations and parentheticals stay with the term they follow:

```markdown
Performance management [bridges the [strategy-implementation gap]{.highlight}]{.fragment} [by providing [systematic measurement]{.highlight},]{.fragment} [[behavioral incentives]{.highlight},]{.fragment} [and [feedback mechanisms]{.highlight} that ensure strategic objectives are achieved.]{.fragment}
```

Replace inline term highlights that are fragments of their own (`[term]{.fragment .highlight-current}`, `[term]{.fragment .highlight}` in a visible sentence). Lists that build item by item (`.fade-in-then-semi-out`, plain `.fragment` enumerations) stay as they are.

## 3a. Speaker Notes

Headings inside `:::notes` (e.g., `### Strategy as Plan {visibility=hidden}`) structure the HTML wiki. In revealjs they would end the slide early and push the notes and everything after them out of the slide; `lib/filter/notes-headings.lua` turns them into bold paragraphs in the slides only, so keep using them.

## 4. Discussion Slides

1. `## Exercise {.discussion-slide}` shows the running header (section title) and its heading as a normal headline.
2. A level-1 discussion slide (`# Recap {.discussion-slide}`) has no section: its heading becomes the dotted label, and the first `:::medium` paragraph is the large title. Give these slides a `:::medium` lead.
3. Keep the introductory sentence before any numbered list (hard rule 3) and the closing `{{< countdown "X:00" top="0">}}`.

## 5. Layout Fit

Fixes that worked on SPM 26WT, in order of preference:

| Problem | Fix |
|---|---|
| Long list (review questions, takeaways) | Split with `{.slide-parts}` into `::: slide-part` blocks (the lead repeats on each slide; the HTML shows one list) |
| Exercise with a long template | `{.slide-parts}`: instructions and countdown in the first part, the template in a part with `title="Template"` |
| Slightly too tall text or table (under about 80px) | Wrap in `::: smaller` or add `.smaller` to the fragment or incremental div |
| Figure or image | Set `height` (r-stack frames, figures, column images); iframes at 640×360 |
| Long reference table (schedule) | Keep `.scrollable`; splitting would split the HTML table |


1. Headlines are larger (`.large` size, 2.4em) and capped at the content width (798px); keep headlines short (1 to 4 words) and check dense slides for overflow.
2. Body text runs to the content measure; condense slides that relied on the full slide width, moving detail into `:::notes` (inside `:::: html-hidden` for the condensed slide version).
3. Tables size their columns automatically (short columns on one line, only the widest wrap), also inside `::::columns`. Do not set manual column widths.
4. Avoid muted text on slides; use `:::medium` for key statements.

## 6. Checks

Never run `quarto render` or `quarto preview` (see `CLAUDE.md`). Check statically instead:

1. **Fenced divs:** every `:::` opener has exactly one bare closer (an unbalanced fence triggers the "string was found in the document: :::" warning).
2. **Agenda:** run `lib/filter/section-title.lua` and `lib/filter/agenda.lua` through Pandoc with a `quarto` stub (`is_format` returning `revealjs`) and inspect the generated rows.
3. **Leftovers:** no `slide-theme: classic`, `data-background-image` in title attributes, `# Agenda` slides, `.highlight-current-blue`, `.highlight-blue`, `.link-color`, `.headline-only` on listed section headings, or `#` headings other than `.section-title`, `# Q&A`, and `# Literature`.
4. **Citations:** keys exist in the course's `literature.bib`.
5. Editing many decks at once crashes the author's running preview; tell the author to restart it.

## 7. Visual Review and Follow-Up

After the static checks, review every slide of every migrated deck in the author's running preview (open it in the browser; never start a preview or render yourself).

1. **Viewport fit:** check that the content of each slide fits the slide, with all fragments shown. Reveal's print view lays out every slide at once with fragments visible, so no navigation is needed: open `slides.html?print-pdf`, then run in the page

   ```js
   [...document.querySelectorAll('.reveal .slides section.slide')]
     .filter(s => s.scrollHeight - s.clientHeight > 2 || s.scrollWidth - s.clientWidth > 2)
     .map(s => `${s.id}${s.classList.contains('scrollable') ? ' [scrollable]' : ''}: `
       + `+${s.scrollHeight - s.clientHeight}px tall, +${s.scrollWidth - s.clientWidth}px wide`)
   ```

   Validated on SPM 26WT. Notes:
   - The preview renders a deck on request: wait about 10 seconds after opening it, and check that the URL names the right deck and the slide count is above 0 before trusting "all fit".
   - In the background tab, Reveal never splits the print view into `.pdf-page` elements (count 0); the slides are still laid out at their fixed size, so the measurement holds.
   - Do not step through slides with `Reveal.slide()` in a loop: in a background tab, Chrome pauses animation frames and the page freezes.
   - `.scrollable` slides scroll in the presentation but are cut off in print and PDF exports; report them separately. Long literature lists are expected to scroll.

   Then look at the flagged slides and a sample of the others (screenshots), also for overlaps the measurement misses (headline and countdown, running header and content, table columns) and for leftovers of the classic look inside figures (e.g., the old blue `#0333ff` in SVGs).
2. **Flag, then fix:** list every slide that overflows, every exception to this checklist, and everything that does not render or behave as expected (deck, slide id, problem). Show the list to the author, then work through it: condense or split slides, move detail into `:::notes`, or fix the theme or filters when the problem is general.
3. **Update the instructions:** add what the review taught (new rules, exceptions, fixes) to this file and the other files in `.claude/lecture-style/`, so the next migration starts from the improved checklist.

## Related Files

- `lib/theme/awe-editorial.scss`, `lib/theme/awe-editorial.html`: theme styles, running header, section numbers, table fitting.
- `lib/filter/section-title.lua`: adds `.headline-only` to `.section-title` headings (revealjs).
- `lib/filter/notes-headings.lua`: headings inside `:::notes` become bold paragraphs (revealjs).
- `lib/filter/agenda.lua`, `lib/filter/slide-parts.lua`, `lib/filter/highlight-color.lua`, `lib/filter/slide-theme.lua`.
