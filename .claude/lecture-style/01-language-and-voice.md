# Language and voice

**Language:** English throughout. `lang: en` in every YAML front matter. No German content (German-medium courses live elsewhere and use a different register).

**Tone:** Academic but direct. Never chatty; never bureaucratic. A clear lecture by an expert who respects the audience's intelligence.

**Person:**
- Second person ("you will be able to", "your task is") for student-facing instructions.
- First-person plural ("we follow", "we have established") sparingly for collective narration.
- Third person for scholarly claims ("@mintzberg1987strategy argues that…").

**Sentence rhythm:**
- Short declarative sentences in slide-visible content.
- Full analytical sentences in notes and prose.
- Paragraph breaks every 3–5 sentences in extended prose.
- Rhetorical questions at transitions ("So what does this mean for strategy formation?").

## Concept introduction pattern (six steps)

1. Motivating hook: quote (blockquote), question, or brief case reference.
2. Formal definition with citation.
3. Framework decomposition (elements, phases, types); animated on slide, prose in notes.
4. Worked example, often a tech company (Netflix, Apple, Salesforce, Google, Anthropic).
5. Exercise or discussion prompt if appropriate.
6. Synthesis sentence capturing the core insight.

## Citations

Pandoc-style bibliography keys only.

| Form | Syntax | Renders as |
|---|---|---|
| Inline author-year | `@key` | "As @mintzberg1987strategy argues…" |
| Parenthetical | `[@key]` | "…has been shown [@barney1995looking]." |
| With page | `[@key, p. 18]` | "…[author 1995, p. 18]." |
| Multiple | `[@key1; @key2]` | "…[a 2020; b 2021]." |
| Footnote | `[^label]` | Defined elsewhere with full `@key`. |

Never write "et al." manually; Quarto/CSL handles pluralization.

## Vocabulary

**Prefer:**
- "solid understanding of" (SPM learning objectives)
- "you will be able to:" (DL learning objectives, numbered, verb-led)
- "Key takeaways" (SPM closing)
- "Latticework update" (DL closing)
- "Review and consolidation" (exam-prep sections)
- "Discussion" / "Reflection" / "Exercise" (in-class activities)
- Technical terms in English even in descriptive prose

**Avoid:**
- "important to note"
- "it is worth mentioning"
- "In summary, we have seen that…" and other trailing summaries
