# Reader vendored SwiftUtilities parity

Reader currently carries SwiftUtilities as an ordinary vendored directory rather than the canonical public repository.

Comparison against canonical `lake-of-fire/SwiftUtilities/main` showed:

- `Package.swift` is byte-identical.
- Canonical main already has the newer stable-hash implementation, including sequence hashing and `stableHashHex`; that code is preserved.
- Reader's vendored copy has three production changes absent from canonical main:
  1. Catalyst-safe `Fonts.swift` AppKit conditional.
  2. `ManabiSystemUIFontCSS` variables and deterministic CSS point-size generation.
  3. Generation-fenced `NSViewRepresentable` window reporting so deferred callbacks from an older binding cannot overwrite a replacement binding.
- Reader also carries focused CSS and window-accessor tests that were absent from canonical main.

This PR ports only those Reader-owned production/test deltas into canonical main. It deliberately does not replace canonical `StableHash.swift` with Reader's older version.

Qualification runs the complete package tests in macOS Debug and Release, strictly typechecks StableHash.swift and the three ported production files with warnings as errors, and builds the complete package for Mac Catalyst. The retained full-package tests allow existing unrelated canonical warnings.

This makes canonical SwiftUtilities a usable convergence target for Reader and a public dependency fixture for Lake integration qualification.

No Reader root pin, schema, persisted identity, signing, rollout, or CloudKit change.
