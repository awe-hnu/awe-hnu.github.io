# CLAUDE.md

## Lecture authoring style

Hard rules first; always check these before writing:

@.claude/lecture-style/00-hard-rules.md

Topical guides (load as needed):

- @.claude/lecture-style/01-language-and-voice.md
- @.claude/lecture-style/02-structure.md
- @.claude/lecture-style/03-quarto-markup.md
- @.claude/lecture-style/04-dual-format.md
- @.claude/lecture-style/05-anti-patterns.md
- @.claude/lecture-style/06-open-questions.md

## Rendering

Never run `quarto render` or `quarto preview` yourself, not even on a copy of the project outside the repository. Manual renders break the author's running preview. Check changes statically instead (markup, citation keys against `literature.bib`, style rules), and leave rendering to the author.
