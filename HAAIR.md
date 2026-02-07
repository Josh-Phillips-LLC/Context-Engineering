
# HAAIR: Human and AI Resources

## Executive Summary

As artificial intelligence systems transition from passive tools to **active agents**, organizations are discovering a structural gap in how responsibility, authority, and access are defined. Most enterprises place AI systems under IT or Operations, treating them as software assets. This framing is insufficient.

AI agents behave less like software and more like **actors**: they take actions, follow instructions, escalate issues, and can cause harm or value at scale. Managing actors has always been the domain of **Human Resources (HR)**. This paper proposes an evolution of HR into **HAAIR — Human and AI Resources** — a function responsible for defining roles, responsibilities, authority boundaries, and access for *both humans and AI agents*.

The core thesis is simple:

> **Roles define responsibility. Responsibility defines authority. Authority defines access.**

When AI agents are introduced without this chain, governance failures are inevitable.

---

## The Structural Problem with AI Governance Today

Most organizations manage AI through the same lens as traditional software:

- IT owns the system
- Operations executes workflows
- Security reacts to incidents
- HR documents roles after the fact

This model assumes humans are the only true actors. AI breaks that assumption.

AI agents:

- operate continuously
- execute instructions literally
- scale mistakes instantly
- do not intuit "this isn’t my job"

Placing such systems under Operations or IT without role clarity leads to over-privileged agents, unclear accountability, and brittle controls.

---

## Why HR Is the Right Home (Even If It Doesn’t Know It Yet)

HR already specializes in:

- Role definition
- Responsibility boundaries
- Separation of duties
- Approval and escalation paths
- Access derived from role, not identity

These concepts are traditionally applied to humans, but they are *actor-agnostic*. AI agents require the same scaffolding, just without the social intuition humans rely on.

In other words:

> **AI agents don’t introduce new governance problems — they expose unresolved ones.**

---

## From HR to HAAIR

HAAIR (Human and AI Resources) extends HR’s mandate to include non-human actors.

Under HAAIR:

- Humans and AI are both **role occupants**
- Roles are defined independently of who or what fulfills them
- Tools and models are implementation details, not organizational primitives

This reframing allows organizations to reason consistently about accountability, regardless of whether the actor is human or artificial.

---

## Role-Based Design: The Missing Abstraction

The foundational unit of governance is not the tool, model, or system.

It is the **role**.

A role defines:

- Purpose
- Responsibilities
- Explicit non-responsibilities
- Authority boundaries
- Escalation conditions
- What "success" looks like

Once roles exist:

- Humans can be assigned to roles
- AI agents can be assigned to roles
- Access can be granted based on role
- Audits can reason about intent and scope

This is how organizations already manage people. AI simply forces the model to be explicit.

---

## Custom Agents as Job Descriptions

In this model, a "custom agent" is not a special class of AI.

It is:

> **An agent operating with a predefined job description.**

The job description (sometimes called a *role charter*) is loaded before the agent acts. The agent does not infer its identity by reading policy documents; it already knows who it is, what it is allowed to do, and when it must stop.

This dramatically reduces ambiguity, drift, and unintended behavior.

---

## Why IT Alone Cannot Solve This

IT excels at:

- systems
- infrastructure
- reliability
- capability enforcement

But IT typically answers the question:

> *What can this system do?*

HAAIR answers a different question:

> *What should this actor be allowed to do?*

Capability without responsibility is risk.

---

## A Practical Example

Consider two roles:

- **Governance Analyst** — analyzes documents and proposes changes
- **Documentation Technician** — implements approved changes verbatim

Both roles may be fulfilled by AI agents.

But:

- Only one may propose
- Only one may execute
- Neither may approve

Without role clarity, these distinctions collapse into a single overpowered agent. With roles, separation of duties is preserved.

---

## Implications for Organizations

Adopting a HAAIR mindset enables:

- Clear AI accountability
- Safer autonomy
- Vendor-agnostic agent design
- Auditable decision-making
- Reduced blast radius for mistakes

It also forces long-overdue clarity in human governance.

---

## Making Human Resources More Effective with AI

AI is already present in most workplaces, regardless of whether leadership has formally acknowledged it. Employees routinely use AI tools to draft documents, analyze information, and accelerate decision-making as part of their everyday work.

When this usage is informal or unacknowledged:

- AI influences outcomes without clear accountability
- responsibility is implicitly delegated
- access and authority are shaped by convenience rather than design

This is not a failure of employees, nor is it a problem that can be solved by prohibition. It is a signal that organizations lack a deliberate model for how humans and AI should work together.

HAAIR provides a constructive alternative. By defining clear roles and role boundaries, organizations can intentionally **pair humans with AI agents** in ways that increase productivity while preserving accountability.

Under this approach:

- the human remains the accountable role-holder
- the AI agent is designed to operate within a defined role charter
- the relationship between human and agent is explicit, visible, and governed

Rather than replacing human judgment, properly designed agents augment it. They handle analysis, preparation, and execution within scope, allowing human role-holders to focus on decision-making, oversight, and accountability.

In this way, HAAIR does not just govern AI — it enables Human Resources to actively design safer, more effective human–AI working relationships, turning an unmanaged reality into a deliberate organizational capability.

## Conclusion

AI agents do not necessarily replace humans.

They force organizations to confront how poorly responsibility has been defined all along.

HAAIR is not about adding bureaucracy. It is about restoring a missing abstraction: **roles as the foundation of authority and access**.

Organizations that adopt this model will scale AI safely. Those that do not will continue to treat actors like tools — until failure makes the distinction unavoidable.

---

## Status

This document is exploratory. It is intended as a conceptual white paper, not a binding policy.
