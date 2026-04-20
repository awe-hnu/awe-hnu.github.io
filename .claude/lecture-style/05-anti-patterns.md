# Anti-patterns

Things consistently absent. Do not introduce them.

## Typographic

- No em dashes where a semicolon, comma, parenthesis, or sentence break works. See `00-hard-rules.md`.
- No punctuation outside a bold span. See `00-hard-rules.md`.
- No curly/smart-quote inconsistencies; use straight quotes in Markdown source.
- No all-caps emphasis; use bold or italics.

## Content

- No emoji in headings, body, or bullets (the `🧐` in SPM admin title is an exception, not a pattern).
- No filler slides; every slide has a purpose.
- No inline HTML styling (`<span style="...">`) except for embedding iframes (Menti, TED, YouTube).
- No "In conclusion, …" or "To summarize, …" trailers; `# Key takeaways` serves that role.
- No generic motivational statements not grounded in a citation or example.
- No `:::notes` that just transcribe the slide bullets; notes expand on what the slide compresses.

## Structure

- No passive-voice learning objectives ("students will be introduced to…"); always active verb with student as subject.
- No figures without captions and `#fig-xxx` references.
- No tables without `{#tbl-xxx}` captions.
- No callouts outside `:::notes` except for genuinely supplementary deep-dives.
- No mixing SPM and DL learning-objective styles within one course.
- No `# Literature` section without the `{#refs}` div immediately beneath it.

## Markup

- Do not nest `:::html-hidden` inside `:::notes`; mutually exclusive patterns.
- Do not use `:::warning` or `:::tip` callouts; only `:::callout-note`.
- Do not add `suppress-bibliography: true` to content units (admin/assignment files only).
