# Hard rules

Non-negotiable. Check before every write. These override anything else.

1. **Em dashes (—) are a last resort.** Prefer a semicolon, comma, parentheses, or splitting into two sentences. Only reach for an em dash when no other punctuation produces an acceptable result. Same applies to en dashes used parenthetically.

2. **Punctuation belongs inside the bold span, not after it.** When a label or lead-in is bolded and followed by `:`, `?`, `,`, `.`, `!`, etc., the punctuation must be part of the bolded text.
   - Correct: `**Example:**`
   - Wrong: `**Example**:`
   - Applies to every `**…**` or `__…__` used as a label, callout lead-in, list-item prefix, or definition term.

3. **Slides never start with a list or table.** Every content slide opens with an introductory sentence that states what the following list, table, definition list, or figure shows; it sits inside the same `:::: html-hidden` block as the list when the slide content is gated.
   - Correct: `@kitchenham2007guidelines distinguish three categories of systematic review.` followed by the list.
   - Wrong: a slide whose first visible element after the heading is `::: incremental`, a bullet, or a table row.
   - Applies to exercise slides as well (e.g., "As a team, …" before the numbered steps). Exempt: hook slides (`.no-headline .vertical-center`), agenda slides, quote slides, and section dividers (`.headline-only`).
