# Building Microservices -- Quick-Reference Guide

When to use each command and skill for microservice-related work. Scan the "I want to..." column to find the right tool.

---

## System-level decisions

| I want to... | Use |
|---|---|
| Design a new microservice system from scratch | `/design-microservice-system` |
| Decide whether to use microservices or stay with a monolith | `/design-microservice-system` (step 2 applies monolith-first default) |
| Audit how healthy my existing microservice architecture is | `/review-microservice-architecture` |
| Understand what coupling types exist between my services | `/review-microservice-architecture` (step 3) |
| Check if my team structure matches my service boundaries | `/review-microservice-architecture` (step 11) |

## Building and evolving services

| I want to... | Use |
|---|---|
| Build a new microservice from scratch | `/create-microservice` |
| Know what every well-built microservice must have (good-citizen checklist) | `/create-microservice` (step 8) or **microservice-patterns-g** skill (Resiliency + Observability) |
| Extract a service from an existing monolith | `/extract-microservice` |
| Split a service that has grown too large | `/extract-microservice` (same principles apply to service-to-service extraction) |
| Plan a feature change involving microservices | `/plan` (Microservices lens activates automatically) |

## API and communication

| I want to... | Use |
|---|---|
| Make a breaking change to a service API | `/evolve-microservice-api` |
| Choose between REST, gRPC, and message brokers | **microservice-patterns-g** skill -- Communication Design (style before technology) |
| Design an event-driven communication pattern | **microservice-patterns-g** skill -- Communication Design |
| Set up consumer-driven contract testing | **microservice-patterns-g** skill -- Testing Strategy + reference.md Ch 9 |
| Design a saga for a cross-service workflow | **microservice-patterns-g** skill -- Workflow and Sagas |

## Operations and quality

| I want to... | Use |
|---|---|
| Set up observability for my services | **microservice-patterns-g** skill -- Observability |
| Define SLOs and error budgets | **microservice-patterns-g** skill -- Observability |
| Add resiliency patterns (circuit breakers, timeouts, etc.) | **microservice-patterns-g** skill -- Resiliency |
| Improve security posture of my microservices | **microservice-patterns-g** skill -- Security |
| Choose a scaling strategy | **microservice-patterns-g** skill -- Scaling (four axes in order) |
| Design a testing strategy for microservices | **microservice-patterns-g** skill -- Testing Strategy |

## Review and debugging

| I want to... | Use |
|---|---|
| Review a PR involving microservice changes | `/review-pr` (Microservices lens activates automatically) |
| Review someone's proposed microservice plan | `/review-plan` (Microservices lens activates automatically) |
| Debug a distributed system issue | `/debug` + **microservice-patterns-g** skill -- Resiliency and Observability |
| Investigate a production incident | `/investigate-incident` + **microservice-patterns-g** skill -- Resiliency |

## Deep reference

| I want to... | Use |
|---|---|
| Look up a specific Newman principle or anti-pattern | **microservice-patterns-g** reference.md (organised by chapter) |
| Read the full book extractions chapter by chapter | `extraction-ch01-04.md` through `extraction-ch14-16.md` |
