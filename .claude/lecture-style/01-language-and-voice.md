# Language and voice

**Language:** English throughout. `lang: en` in every YAML front matter. No German content (German-medium courses live elsewhere and use a different register).

**Tone:** Academic, functional, and direct. Never chatty; never bureaucratic; never essayistic. A clear lecture or technical brief by an expert who respects the audience's intelligence.

**Person:**
- Second person ("you will be able to", "your task is") for student-facing instructions.
- First-person plural ("we follow", "we have established") sparingly for collective narration.
- Third person for scholarly claims ("@mintzberg1987strategy argues that…").

**Headings and Titles:**
- **Target length:** Prefer extremely short labels—typically 1 to 3 words (hard cap of 4 words).
- **Preferred patterns:** Minimal, foundational noun phrases or direct action pairs (e.g., "Definition", "Foundations", "Leading Change", "Hypotheses for Change").
- **Ban narrative and conversational formulas:**
    - No journey structures: Never use "From [X] to [Y]" (e.g., use "Topic Selection", not "From notes to a candidate topic").
    - No reveal hooks: Never use "What [X] actually gives you / means / does" (e.g., use "Raw Inputs", not "What an input actually gives you").
    - No rhetorical questions in titles: Convert them to direct nouns (e.g., use "Question Viability", not "What makes a question answerable?").
    - No descriptive idioms: Convert narrative procedures into standard technical terms (e.g., use "Two-Pass Review", not "Two passes over a talk").
- **Focus:** Name the artifact, analytical state, or direct task directly (e.g., "Claim Grouping", "Notes Synthesis", "Scoping Criteria").
- **Capitalization:** Title case for every heading level (`#` through `####`). Capitalize the first word, the last word, and all nouns, verbs, adjectives, adverbs, and pronouns. Lowercase articles ("a", "an", "the"), coordinating conjunctions ("and", "but", "or", "nor", "for", "so", "yet"), the conjunction "as", and short prepositions under five letters ("in", "on", "at", "to", "of", "for", "from", "with", "into") unless they open or close the heading. Keep the established combining words "x" and "vs."/"vs" lowercase wherever they appear (e.g., "Rider x Elephant x Path", "Strategies vs. Tactics"). Examples: "Approaches to IS Strategy", "Good and Bad Emotions", "The Kernel", "Strategy as Plan".

**Sentence rhythm:**
- Short declarative sentences in slide-visible content.
- Full analytical sentences in notes and prose.
- Paragraph breaks every 3–5 sentences in extended prose.
- Rhetorical questions at transitions sparingly ("So what does this mean for strategy formation?").

**Prose Style & Voice: Anti-Aphorism & Economy Rules:**
- **Ban rhetorical parallelism and artificial antithesis:** Never use formulas like "X is not Y, it is Z" or "They do not give you A; they give you B." State the operational fact directly.
- **Eliminate narrative build-up and reveal structures:** Never set the stage with what a method fails to do before announcing the solution (e.g., cut "This is the step X does not do for you...", "Here is where synthesis actually happens").
- **Compress explanatory sequences into single functional clauses:** Chain prerequisites, methods, and outcomes into direct, operational sentences rather than staging them over multiple beats.
    - *Bad:* "This is the step open coding does not do for you: it produces isolated, tagged observations, one per input. Clustering, a lightweight form of axial coding done as a mind map instead of a formal category scheme, is where synthesis actually happens."
    - *Good:* "After open coding, which produces isolated, tagged observations per input, clustering helps you synthesize findings by applying a lightweight form of axial coding."
- **Avoid pseudo-profundity and fortune-cookie phrasing:** Do not attempt to summarize complex observations into poetic aphorisms, solemn maxims, or intellectual soundbites.
- **Drop meta-commentary and lens-framing:** Cut academic metaphors like "disciplinary lenses," "conceptual frames," "candidate mysteries," or "tapestry." Say what the disciplines actually do or what the data indicates.
- **Favor concrete operational language:**
    - *Bad:* "A breakdown is not noise. It is a candidate mystery."
    - *Good:* "Treat unexpected errors as anomalies worth investigating rather than outliers to discard."
    - *Bad:* "Practitioners rarely hand you a research question. They hand you practice..."
    - *Good:* "Practitioners describe everyday operational problems, which you must translate into formal research questions."
- **Default to plain subject-verb-object structure:** Write like an experienced, grounded technical colleague writing internal documentation, not an academic essayist or keynote speaker.

**Style:**
1. Direct Affirmation: Define and explain all concepts exclusively by what they are. Focus entirely on positive, straightforward descriptions.
2. Avoid Structural Contrasts: Do not use phrases structured around binary opposites, such as "this is not [X], this is [Y]."
3. No Strawman Arguments: Address the core substance of the prompt directly. Never introduce hypothetical, weakened, or incorrect counterarguments simply to dismantle them.
4. Syntactic Economy: Prefer compound-complex functional statements (e.g., "After [antecedent], [action] achieves [target] by [mechanism]") over dramatic, episodic narrative sequences.

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
- "Key Takeaways" (SPM closing)
- "Latticework Update" (DL closing)
- "Review and Consolidation" (exam-prep sections)
- "Discussion" / "Reflection" / "Exercise" (in-class activities)
- Technical terms in English even in descriptive prose

**Avoid:**
- "important to note"
- "it is worth mentioning"
- "In summary, we have seen that…" and other trailing summaries


