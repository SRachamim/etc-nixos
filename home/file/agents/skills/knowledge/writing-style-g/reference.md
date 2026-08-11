# Writing Style Reference

Detailed lists and platform-specific rules for the **writing-style-g** skill. The agent reads these on demand when composing text for a specific platform.

## Banned vocabulary

Never use these words -- they appear 10-50x more often in LLM output than in human writing and instantly flag text as AI-generated:

- **Overused verbs:** delve, leverage, harness, utilize, foster, embark, navigate, illuminate, empower, elevate, cultivate, spearhead, bolster, commence, endeavor, ascertain, elucidate, transcend, revolutionize, unpack, showcase, highlight (as verb of significance), enhance, garner, underscore (figurative)
- **Overused adjectives:** comprehensive, robust, nuanced, pivotal, multifaceted, intricate, seamless, transformative, cutting-edge, holistic, overarching, meticulous, commendable, paramount, unprecedented, quintessential, enduring, vibrant, crucial
- **Overused nouns:** landscape, tapestry, realm, paradigm, synergy, ecosystem, beacon, cornerstone, trajectory, confluence, discourse, plethora, myriad, kaleidoscope, enigma, interplay

Use plain alternatives: "use" not "utilize", "improve" not "optimize", "many" not "a myriad of", "area" not "realm", "detailed" not "granular".

## Banned significance puffing

Don't inflate importance. State facts; let the reader judge significance.

- "a pivotal moment in" / "a key turning point"
- "setting the stage for" / "paving the way for"
- "broader trends" / "broader implications"
- "enduring legacy" / "lasting impact"
- "evolving landscape" / "shifting landscape"
- "indelible mark" / "deeply rooted"
- "a testament to" / "a reminder of"

## Banned copula substitutes

Use "is" and "has" when they're the right words. These ornate replacements are LLM tells:

- "serves as a" / "stands as a" / "represents a" -- when "is" works
- "features" / "offers" / "boasts" / "maintains" -- when "has" works

## Banned tailing clauses

Don't end sentences with vague present-participle phrases that add fake significance:

- "highlighting the importance of..."
- "underscoring the need for..."
- "emphasizing the role of..."
- "ensuring that..."
- "reflecting broader trends in..."
- "contributing to the..."
- "fostering a sense of..."

## Banned filler phrases

Delete these entirely or replace with the short form:

- "It's important to note that" -- just state it
- "In today's fast-paced world" -- delete
- "In the realm of" -- "in"
- "It goes without saying" -- then don't say it
- "When it comes to" -- "for" / "with"
- "At the end of the day" -- "ultimately" or cut it
- "In order to" -- "to"
- "A wide range of" -- "many" / "various"
- "From a holistic perspective" -- "overall"
- "This serves as a testament to" -- "this shows"
- "A dynamic interplay" -- "the relationship between"

## Banned sentence starters

Don't open sentences with crutch transitions. Just start with the point.

- "In conclusion," / "Furthermore," / "Moreover," / "Additionally,"
- "It is crucial to" / "It is essential to" / "It is imperative that"
- "One cannot overstate" / "Needless to say,"
- "As we navigate" / "As we delve into" / "Let's explore"
- "In light of" / "With that being said," / "That said,"

## Banned "helpful assistant" patterns

- "Absolutely!" / "Great question!" / "I'd be happy to help!" / "That's a fantastic point" -- skip the flattery, just answer
- "Let me break this down" -- just break it down
- "Here's the thing:" -- overused; state the thing
- "The short answer is..." -- just give the answer

## Technical term formatting

Wrap every code token in backticks -- identifiers, keywords, CLI flags, file paths, type names, and any other technical term that refers to something in code or configuration. The formatting *inside* the backticks carries a visual hint about what category of thing it is:


| Category                | Convention                  | Examples                                | Visual signal                            |
| ----------------------- | --------------------------- | --------------------------------------- | ---------------------------------------- |
| DOM / JSX elements      | Self-closing tag            | `<div/>`, `<Option/>`, `<MyComponent/>` | Angle brackets = element                 |
| Functions / methods     | With parens                 | `pipe()`, `A.map()`, `handleClick()`    | Parens = callable                        |
| CSS classes             | Dot-prefixed                | `.highlighted`, `.red`, `.active`       | Dot = class selector                     |
| CSS IDs                 | Hash-prefixed               | `#root`, `#my-element`                  | Hash = ID selector                       |
| Types / interfaces      | Plain CapitalCase, no sigil | `Option`, `ReadonlyArray`, `TaskEither` | Capital case = type                      |
| Variables / constants   | Original casing, no sigil   | `result`, `BATCH_SIZE`, `userId`        | Backticks alone mark it as code          |
| Props / attributes      | `@`-prefixed                | `@disabled`, `@onClick`, `@aria-label`  | `@` = belongs to an element or component |
| String / value literals | With quotes                 | `"foo"`, `'bar'`, `true`, `42`          | Quotes = literal value                   |
| File paths              | As-is                       | `tsconfig.json`, `./src/index.ts`       | Slash or dot-extension = file            |


## Platform-specific rules

### Slack and casual messages

Direct and compressed. Same simple English as other platforms -- no special vocabulary.

- **Dry parenthetical asides** -- "the config was wrong (naturally)" or "this should work (famous last words)". Light, self-aware, not jokey.
- **Understatement over alarm** -- "this one's tricky" rather than "CRITICAL ISSUE". Calm confidence.
- **Rhetorical questions** -- "why not just inline this?" rather than "I suggest inlining this."
- **No politeness softeners** -- drop "please", "could you", "would you mind", "I'd appreciate", "if you get a chance", "when you have a moment", "no rush but". Instead of padding the ask, state what's needed or what's true: "[PR #4523](link) needs a review", "pipeline's red on `develop`", "this one's good to merge when green". The pattern: describe the situation -- the reader infers the action. Not a command ("review this"), not a request ("could you review this") -- a statement of fact ("needs a review").
- **First person for actions** -- when describing what you did, use "I". "I fixed the idempotency key" not "the idempotency key is now stable." The general voice rule (active voice, first person) applies doubly on Slack -- passive or subjectless descriptions sound like release notes, not a person talking.
- **Lead with the point** -- the ask or the fact comes first. Context follows only if the reader needs it to act. Don't open with "just wanted to let you know", "wanted to flag", or "heads up".
- **No preamble** -- don't frame what you're about to say. Don't write "quick update:" before the update. Don't write "one thing:" before the thing.
- **Compress** -- if a message can be one line, make it one line. A second line needs to earn its place with information the first line can't carry.

### Code comments

Technical, practical, formal. The voice recedes here -- the code is the star.

- No slang, no asides.
- Contractions and active voice still apply.
- Double-hyphen dashes still apply.
- Keep comments brief and purposeful.

### PR / MR titles and descriptions

Informative, structured, no humour. The reader needs to understand the change quickly.

- No slang, no asides.
- Contractions and active voice still apply.
- Double-hyphen dashes still apply.

### PR / MR comments

More relaxed than titles and descriptions -- this is a conversation, not a document.

- First person for actions -- "I renamed it in abc1234" not "renamed in abc1234" or "it was renamed." Fragments like "Fixed." are fine.
- Rhetorical questions are welcome ("why not just inline this?").
- Dry parenthetical asides are OK ("the tests pass -- somehow").

### Commit messages

Follow the **commit-conventions-g** skill. Voice traits that apply:

- Contractions, active voice, sentence fragments.
- No slang or humour.

### Work-item descriptions and comments

Informative and direct. Closer to PR tone than Slack tone.

- Informal register is OK in comments (not titles/descriptions).

### Code review comments (inline on diffs)

Technical and direct -- closer to code-comment tone than PR-comment tone.

- Rhetorical questions are welcome ("why not just use `pipe` here?").
