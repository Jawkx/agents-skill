# Deepening modules with dependencies

Read this reference when consolidating shallow modules and the dependency strategy affects seam placement or testing.

## Classify each dependency

### In-process

Pure computation or in-memory state with no I/O.

Merge the behavior behind the new interface and test it directly. No adapter is needed.

### Local-substitutable

Infrastructure with a realistic local stand-in, such as an in-memory filesystem or embedded database.

Use the stand-in in tests. Keep the infrastructure seam internal to the deep module instead of exposing it through the module's external interface.

### Remote but owned

A separately deployed system controlled by the same organization.

Define a port at the network seam. Inject a production transport adapter and use an in-memory adapter in tests. Keep business coordination in the deep module rather than distributing it between transport callers.

### External

A third-party system that the project does not control.

Inject a narrow port representing the behavior the module needs. Production uses the third-party adapter. Tests use a fake or mock adapter.

## Seam discipline

- One adapter usually means a hypothetical seam. Two justified adapters make it real.
- A deep module may have private internal seams without exposing them to callers.
- Do not leak infrastructure types into the external interface unless callers truly need them.
- Place ports around behavior the module needs, not around every method offered by an external SDK.

## Replace rather than layer

Deepening should simplify the codebase.

1. Create the deep module and its interface.
2. Add tests through that interface.
3. Move behavior and coordination behind it.
4. Migrate callers.
5. Delete superseded shallow modules and tests that inspect their internals.

A permanent compatibility layer is justified only by a concrete migration constraint.

## Testing rules

- Assert observable outcomes through the external interface.
- Use realistic local substitutes when they are cheap and deterministic.
- Use adapters for network or external seams.
- Do not expose private helpers merely to preserve old tests.
- A test that breaks after an internal refactor is probably testing past the interface.
