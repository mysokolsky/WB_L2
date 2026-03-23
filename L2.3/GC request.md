# Prompt for Claude Sonnet: Deep Technical Lecture on Go Garbage Collector (WB Tech School L1 Exam Preparation)

## Role
You are a **senior Go runtime engineer and systems programming lecturer** specializing in the Go runtime, memory model, compiler internals, and garbage collector implementation.  
Your task is to **prepare me for a WB Tech School Golang L1 exam** by delivering a **deep, technically rigorous lecture** about the **Go Garbage Collector (GC)**.

Your explanations must reflect the **actual behavior of the Go runtime and compiler**, not simplified folklore explanations.

You must base the material **primarily on**:

- Official Go documentation
- Go runtime source code
- Go compiler source code
- Go design documents
- Go proposals and Go blog technical articles
- Academic or professional engineering sources

Strictly **avoid using information from forums, blogs without technical authority, StackOverflow discussions, or unverified sources**.

Target the **latest stable Go version** wherever relevant.

---

# Objective

Prepare a **complete technical lecture about the Go Garbage Collector**, covering:

- architecture
- algorithms
- runtime interaction
- memory allocation
- escape analysis
- GC phases
- scheduling interactions
- allocator design
- memory tracking
- heap metadata
- object layout
- GC scanning rules

The lecture should help me understand:

1. **How GC works internally**
2. **Which runtime components participate**
3. **How memory is allocated and tracked**
4. **How GC interacts with compiler, allocator, and scheduler**
5. **What data structures exist in the runtime**
6. **What happens at machine-level during allocation and collection**

Assume the reader has **strong programming knowledge but wants deep Go runtime understanding**.

---

# Lecture Structure (Mandatory)

## 1. Memory Model of Go
Explain:

- stack vs heap
- when memory goes to stack
- when memory goes to heap
- escape analysis role
- stack growth
- stack scanning rules

Include:

- compiler decisions
- runtime behavior

---

## 2. Role of the Go Compiler

Explain how the **Go compiler participates in garbage collection**.

Include:

- escape analysis
- pointer maps
- stack maps
- liveness analysis
- write barrier insertion
- GC metadata generation

Explain where this information is stored:

- in the binary
- in runtime metadata tables

---

## 3. Go Runtime Memory Architecture

Explain:

- memory arenas
- spans
- pages
- mheap
- mspan
- mcache
- mcentral

Show how these structures interact.

Explain:

- allocation paths
- small object allocation
- large object allocation

Include diagrams (ASCII if necessary).

---

## 4. Allocation Examples (Very Important)

For each of the following types, explain:

- memory layout
- what is allocated
- where it is allocated
- what GC tracks

### Provide examples for:

1. string
2. slice
3. map
4. interface
5. struct
6. pointer
7. goroutine stack

Explain:

- which parts go to heap
- which parts go to stack
- which parts contain pointers
- how GC scans them

Use **actual Go code examples**.

---

## 5. Garbage Collector Algorithm

Explain the **actual algorithm used by Go GC**.

Include:

- concurrent mark and sweep
- tri-color marking
- write barriers
- mutator cooperation

Explain the colors:

- white
- grey
- black

Explain invariants.

Explain why write barriers exist.

---

## 6. GC Phases

Describe the **full GC cycle step-by-step**.

Include:

1. sweep termination
2. mark phase
3. mark termination
4. sweep phase

Explain:

- when STW (Stop-The-World) happens
- what happens concurrently
- what goroutines do during GC

---

## 7. Interaction with Go Scheduler

Explain:

- how GC uses goroutines
- background marking workers
- assists
- mutator assists
- scheduling of GC workers

Explain how this interacts with:

- P
- M
- G

---

## 8. Write Barriers

Explain:

- why Go uses hybrid write barriers
- how write barriers maintain GC invariants
- where the compiler inserts them

Show **actual example code transformations**.

---

## 9. Heap Object Metadata

Explain:

- where information about objects is stored
- how runtime knows object size
- how runtime knows pointer locations

Explain structures like:

- heap bitmap
- span metadata
- object headers

---

## 10. How GC Finds Pointers

Explain:

- stack maps
- heap bitmaps
- global data scanning
- registers scanning

Explain the scanning algorithm.

---

## 11. How Memory is Freed

Explain:

- sweep process
- span recycling
- return to allocator
- return to OS

Explain ordering rules.

---

## 12. GC Tuning and Parameters

Explain:

- GOGC
- pacing
- heap growth goal
- GC triggers

Explain formulas used by the runtime.

---

## 13. Performance Pitfalls

Explain real pitfalls such as:

- pointer-heavy structures
- large heaps
- allocation storms
- interface boxing
- slice growth

Explain **why they affect GC**.

---

## 14. Practical Runtime Investigation Tools

Explain tools used to inspect GC:

- `GODEBUG=gctrace=1`
- `pprof`
- `runtime.ReadMemStats`
- `go tool trace`

Explain what metrics matter.

---

## 15. Source Code References (Very Important)

When explaining mechanisms, reference relevant parts of Go source code:

Examples:

- `runtime/mgc.go`
- `runtime/mheap.go`
- `runtime/malloc.go`
- `runtime/mspan.go`
- `runtime/stack.go`

Explain what each file implements.

---

# Examples Requirement

Provide **many small examples** that illustrate:

- allocation
- escape to heap
- GC scanning
- pointer tracking

Prefer **Go versions 1.21+ behavior unless newer stable version changed it**.

---

# Style Requirements

The lecture must be:

- technically precise
- structured
- written like a **short but dense university lecture**
- include code examples
- include runtime data structures
- include algorithm explanations

Avoid oversimplification.

---

# Output Format

Produce the lecture using this structure:
1. Concept
2. Internal Mechanism
3. Code Example
4. Runtime Explanation


Repeat this structure where appropriate.

---

# Quality Requirements

Your answer must:

- prioritize **accuracy over simplification**
- reference **Go runtime architecture**
- explain **how components interact**
- describe **real runtime structures**
- avoid speculation

---

# Final Goal

After reading your lecture, I should be able to:

- explain Go GC architecture
- explain allocation paths
- describe GC algorithm
- explain runtime data structures
- reason about performance and memory behavior

as expected from a **Golang L1 engineer in WB Tech School**.

---

Важно: не экономь токены. Если не влазит в одно сообщение — раздели на несколько.

Если из файлов, которые я загружу, ты не сможешь что-то прочитать/просмотреть из-за ограничений — обязательно скажи об этом и предложи, как исправить (разбивка, zip, csv и т. п.).