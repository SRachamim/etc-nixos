---
name: building-microservices
description: Microservice architecture principles, patterns, and practices from Sam Newman's "Building Microservices" (2nd ed.). Covers boundary design, communication, sagas, deployment, testing, observability, security, resiliency, scaling, UI decomposition, and organizational alignment. Use when creating, modifying, evolving, extracting, reviewing, or designing microservices or microservice systems.
---

# Building Microservices

Principles and practices from Sam Newman's *Building Microservices: Designing Fine-Grained Systems* (2nd ed., O'Reilly 2021), organised by decision context. Use the **Domain Lookup** table below to load domain-specific guidance from [reference.md](reference.md) on demand. For chapter-by-chapter deep reference, see [reference.md](reference.md). For a quick lookup of which command or skill to use, see [guide.md](guide.md).

## North Star

Independent deployability is the single most important concept. Everything else follows from it.

- **Independent deployability**: change, deploy, and release one microservice without deploying any other. This is not aspirational -- it is the default release discipline.
- **Information hiding** (Parnas): hide as much as possible inside a service; expose as little as possible via external interfaces. Implementation changes must not break upstream consumers.
- **Monolith-first default**: microservices are not the goal. Default to a monolith (or modular monolith) unless there is a justified reason to decompose. Reasons include: delivery contention across many teams, need for independent scaling, or need for technology heterogeneity.
- **Incremental adoption**: turn the dial, don't flip the switch. Extract one service, deploy to production, assess, then decide whether to continue.
- **Microservices buy you options** (James Lewis) -- at a cost. Every option has a strike price. Evaluate the cost of maintaining each option.

**When to apply**: every microservice decision. If a design choice undermines independent deployability, it requires explicit justification.

## Modeling Boundaries

Use domain-driven design to find service boundaries that maximise cohesion and minimise coupling.

### Core concepts

- **Bounded context**: organisational boundary hiding internal complexity; contains one or more aggregates; exposes an explicit external interface.
- **Aggregate**: real-world domain concept with a lifecycle and state machine (Order, Invoice). One aggregate is managed by exactly one microservice. One microservice can own many aggregates.
- **Ubiquitous language**: use the same terms in code and domain conversations. Shared models across contexts may have different names (Customer vs Recipient).

### Coupling taxonomy (low to high)

| Type | Description | Action |
|------|-------------|--------|
| **Domain** | Service A calls B for B's functionality | Unavoidable; minimise downstream fan-out |
| **Temporal** | Both services must be up simultaneously | Use async messaging to decouple availability |
| **Pass-through** | A passes data to B only because C needs it | Hide in intermediary or use opaque blob |
| **Common** | Shared DB, filesystem, or memory | Single owner for mutable state; read-only ref data sometimes OK |
| **Content** | External service directly modifies another's DB | **Never acceptable**; route through owning service's API |

### Boundary quality checklist

1. Can I change and deploy this service independently?
2. Is related business behaviour co-located (strong cohesion)?
3. Are cross-boundary assumptions minimised (loose coupling)?
4. Is internal state hidden (information hiding)?
5. Does one service own each aggregate's lifecycle/state machine?

### Decomposition drivers

Default to **domain-oriented** boundaries. Mix other drivers pragmatically:

| Driver | When it fits |
|--------|--------------|
| Domain (DDD) | Default; business-aligned change isolation |
| Volatility | Fast time-to-market; frequently changing features |
| Data/security | PCI, GDPR, PII segregation into security zones |
| Technology | Different runtime/DB requirements |
| Organisation | Match team ownership; avoid cross-team services |

### Event storming

Events (orange) -> Commands (blue) -> Aggregates (yellow) -> Bounded contexts -> map to services. Run with domain experts; don't let current implementation warp the domain model.

**Anti-patterns**: splitting an aggregate across services; CRUD wrapper services with behaviour leaked to consumers; three-tier horizontal layering as service boundaries; premature fine-grained decomposition before the domain is understood.

**When to apply**: `/design-microservice-system`, `/create-microservice`, `/extract-microservice`, `/review-microservice-architecture`, and any `/plan` involving service boundaries.

## Domain Lookup

| Decision context | Reference section |
|-----------------|-------------------|
| Inter-service communication | Communication Design |
| Cross-service state changes | Workflow and Sagas |
| CI/CD and deployment | Build and Deployment |
| Test strategy for services | Testing Strategy |
| Monitoring and alerting | Observability |
| Security and auth | Security |
| Failure handling and resilience | Resiliency |
| Performance and scaling | Scaling |
| Frontend architecture | User Interfaces |
| Team structure and governance | Organisation and Architecture |

Read the relevant section from [reference.md](reference.md) when working in a specific domain.

## Critical Anti-Patterns (Cross-Cutting)

These are the most dangerous mistakes across all areas. Flag any of these immediately:

1. **Shared mutable database** across services -- destroys independent deployability
2. **Distributed transactions (2PC/XA)** across microservices -- locks, latency, availability death
3. **Long synchronous call chains** (3+ services) -- cascade failure, latency multiplication
4. **Content coupling** -- external service directly modifying another's DB
5. **Shared domain libraries** across services -- coordinated redeploy on every change
6. **Metaversioning** -- system-wide version number coupling all services
7. **Smart middleware** -- business logic in gateways, ESBs, or service meshes
8. **Microservices as the goal** -- activity without outcome; "you don't win by having microservices"
9. **Big-bang decomposition** -- "the only thing you're guaranteed of is a big bang" (Fowler)
10. **Technology before communication style** -- picking Kafka/gRPC before deciding event-driven vs request-response
