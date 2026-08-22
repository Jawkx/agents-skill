# Design it twice

Read this reference when the user wants alternative interfaces or when the first proposal has consequential trade-offs.

## 1. Frame the problem

Before proposing interfaces, state:

- The callers and use cases the module must support
- Constraints every design must satisfy
- Dependencies and their categories from [`DEEPENING.md`](DEEPENING.md)
- What behavior should sit behind the seam
- A small illustrative sketch that clarifies the problem without committing to one answer

## 2. Produce distinct designs

Develop at least three genuinely different interfaces. Use parallel sub-agents when available. Give each design a different constraint:

1. Minimize the interface to one to three entry points.
2. Maximize flexibility for known use cases and extension points.
3. Optimize the common caller so its default path is trivial.
4. When remote dependencies matter, place the seam around ports and adapters.

Do not submit cosmetic variants with renamed methods.

Each design must include:

1. Types, methods, and parameters
2. Invariants, ordering requirements, and error behavior
3. A caller example
4. Behavior hidden by the implementation
5. Dependency and adapter strategy
6. Testing through the interface
7. Where leverage is high and where the interface remains shallow

## 3. Compare and recommend

Present each design separately, then compare them by:

- Depth
- Locality
- Seam placement
- Caller complexity
- Test stability
- Migration cost

Recommend one design. Combine ideas only when the hybrid remains coherent and does not enlarge the interface without a real caller need.
