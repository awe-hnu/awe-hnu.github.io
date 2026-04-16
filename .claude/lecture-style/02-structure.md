# Lecture structure

## Standard content-unit skeleton

```
[YAML front matter]
# Learning objectives          ← always first; incremental list
# Prologue / Introduction      ← optional; motivating quote or short case
# [Section 1] {.headline-only} ← section divider
## [Subsection]                ← content slide(s)
  ...
# Key takeaways                ← incremental bold-term bullets
# Review and consolidation {.scrollable}  ← numbered exam-prep questions, :::smaller
# Homework                     ← specific reading + 3–5 guiding questions
# Q&A {.html-hidden .unlisted .headline-only background-image="../assets/bg.jpg"}
# Literature
::: {#refs}
:::
```

**SPM additionally** opens each unit with `# Recap {.html-hidden}` (bullets summarizing last week).

**DL additionally** opens each session with:
- `# Introduction {.headline-only}` (revealjs-only) containing `## Today's session` (agenda)
- A warm-up or "Latticework check-in" discussion slide
- A "Latticework update" before the closing section

## Admin unit skeleton

Motivation (quote/video) → Discussion → General remarks → Contents (course arc) → Learning objectives → Effort → Schedule (scrollable table) → Q&A → Literature

## Learning objectives styles

| Aspect | SPM | DL |
|---|---|---|
| Lead-in | `After this section, you should have a solid understanding of` | `After completing this unit, you will be able to:` |
| Item form | Noun phrases | Numbered, verb-led, action-oriented |
| Verbs | n/a | Explain, Compare, Analyze, Evaluate, Apply, Reflect, Propose |
| Wrapper | `:::incremental` | `:::incremental` |

Pick one style per course; do not mix within a course.

## Recap, warm-up, closing

| Slot | SPM | DL |
|---|---|---|
| Opener | `# Recap {.html-hidden}` with previous unit's takeaways | "Latticework check-in" discussion slide |
| Closer | `# Key takeaways` | `# Key takeaways` plus "Latticework update" |
| Final slide | `# Q&A {.html-hidden .unlisted .headline-only}` (blue background) | same |

## Exercises and discussions

- Use `.discussion-slide` class.
- Add `.html-hidden .unlisted` so they do not appear in the HTML wiki.
- End every exercise slide with `{{< countdown "X:00" top="0">}}`.
- Typically 5–20 minutes; numbered, concrete instructions.

## Homework

- Specific paper(s), podcast(s), or task(s).
- Followed by 3–8 numbered guiding questions.
- Lives in its own `# Homework` section at the end of the unit.
