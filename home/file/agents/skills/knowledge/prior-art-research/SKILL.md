---
name: prior-art-research
description: Research established patterns and approaches from the functional programming, DDD, and Nix ecosystem literature before committing to a design. Use whenever the agent plans a feature, designs an architecture, or evaluates alternative approaches -- before drafting the solution.

# Prior Art Research

Before designing a solution, search the internet for established patterns, architectures, and approaches that address the same problem domain. Standing on the shoulders of prior art produces better designs than reasoning from first principles alone.

## When to apply

During planning, after the goal is clear but before examining the codebase or drafting a design. Prior-art findings should inform how you read the existing code and which design lenses matter most.

Referenced by: `/plan` (step 2), `/add-agent-behavior` (step 3), `/review-plan` (step 4), `/review-pr` (step 4), and any command that designs or evaluates architecture.

## Source priority

Search for prior art in this order of preference:

1. **Functional programming literature and communities** -- Haskell, Scala/ZIO, F#, fp-ts, Effect-TS, Elm. These ecosystems have mature, well-documented solutions for common domains (state machines, validation, error handling, data pipelines, event sourcing, CQRS).
2. **Domain-Driven Design literature** -- Evans (*Domain-Driven Design*), Wlaschin (*Domain Modeling Made Functional*), Vernon (*Implementing Domain-Driven Design*). DDD provides vocabulary and patterns for modelling complex domains with bounded contexts, aggregates, value objects, and domain events.
3. **Established software design literature** -- Fowler (*Refactoring*, *Patterns of Enterprise Application Architecture*), Hohpe (*Enterprise Integration Patterns*, *The Software Architect Elevator*), GoF patterns adapted to FP idioms.
4. **Nix ecosystem** (when the problem involves system configuration, packaging, module composition, or environment management) -- NixOS Wiki, Nix/nixpkgs manuals, NixOS Discourse, nix-community GitHub org, and established projects (home-manager, nix-darwin, agenix, sops-nix, disko, impermanence). The Nix module system, overlays, and flake patterns offer well-tested compositional solutions for declarative system management.
5. **Open-source implementations** -- repositories, libraries, or frameworks that solve the same or a closely related problem. Evaluate their approach, not just their API.

## How to research

Use the web search tool. Run multiple searches with different angles:

- **Problem-domain terms**: describe the *what*, not the *how*. E.g., "state machine pattern", "event sourcing", "validation pipeline", "retry with backoff".
- **FP-specific queries**: "functional approach to X", "Haskell X pattern", "F# X domain modelling", "fp-ts X".
- **DDD-specific queries**: "DDD pattern for X", "bounded context for X", "aggregate design for X".
- **Nix-specific queries** (when applicable): "NixOS module for X", "home-manager X config", "nixpkgs X overlay", "nix flake pattern for X", "NixOS Discourse X". Search for how established configurations handle the same problem -- module options, activation scripts, system integration.
- **Comparative queries**: "X vs Y pattern trade-offs", "when to use X over Y".

Aim for 3--5 searches. Stop when you find convergence -- multiple sources recommending the same approach -- or when queries stop yielding new information.

## How to evaluate

Not every pattern found is a good fit. Assess each candidate against the project's actual constraints:


| Question                                    | What to look for                                                                                                                                        |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Does it solve the right problem?**        | The pattern addresses the core challenge, not a superficially similar one.                                                                              |
| **Does it fit the language and ecosystem?** | The pattern translates naturally to the project's language (e.g., TypeScript with fp-ts). Patterns native to Haskell's type system may need adaptation. For Nix, check whether the pattern uses the module system idiomatically (option declarations, mkIf/mkMerge, lib functions) rather than fighting it. |
| **Does it fit the existing architecture?**  | The pattern composes with -- or at least does not fight -- the current codebase structure.                                                              |
| **Is it proportionate?**                    | The complexity of the pattern matches the complexity of the problem. Don't introduce CQRS for a CRUD form.                                              |
| **Does it preserve options?**               | The pattern keeps future decisions open rather than locking in irreversible choices (per **architect-thinking** -- Options Thinking).                   |


Adapt the pattern to the context. Cargo-culting a solution from a different ecosystem without translation produces worse results than a simpler, native approach.

## Output

Produce a short summary (3--8 bullet points) covering:

- Which patterns or approaches were found and from which sources.
- Which pattern(s) are the best fit for this problem and why.
- How the chosen pattern should be adapted to the project's constraints.
- Any patterns that were considered and rejected, with a brief reason.

This summary feeds into subsequent planning steps -- codebase analysis, design-lens evaluation, and plan drafting.

## Related skills

- **architect-thinking** -- Options Thinking and Fit for Purpose guide pattern evaluation.
- **decision-priorities** -- the priority ladder (correctness, changeability, DX) breaks ties between candidate patterns.
- **design-lenses** -- the Flexibility lens principles (additive programming, combinators, Postel's law) help assess whether a pattern integrates well.
- **functional-typescript** -- the target idioms and standards that any adopted pattern must align with.