;; META.scm - Meta-level information for Algorithm Shield
;; Media Type: application/meta+scheme

(define meta
  '((architecture-decisions
     ((adr-001
       (status accepted)
       (date "2026-01-24")
       (title "Use ReScript for application logic")
       (context
        "Browser extensions require JavaScript, but TypeScript is banned per RSR."
        "Need type safety and functional programming ergonomics.")
       (decision
        "Use ReScript as the primary application language."
        "Compiles to clean ES6 JavaScript."
        "Strong ML-family type system."
        "Excellent React/JSX support if needed for UI.")
       (consequences
        "Positive: Type safety, functional patterns, RSR compliance."
        "Negative: Smaller ecosystem than TypeScript, team must learn ReScript."
        "Mitigation: ReScript has excellent docs and OCaml compatibility."))

      (adr-002
       (status accepted)
       (date "2026-01-24")
       (title "Use Rust/WASM for rule engine")
       (context
        "Need performant logic programming for rule evaluation."
        "JavaScript is too slow for complex relational queries."
        "Want to compile to WASM for browser compatibility.")
       (decision
        "Implement Minikaren-style engine in Rust, compile to WASM."
        "Use wasm-bindgen for JS interop.")
       (consequences
        "Positive: High performance, type safety, RSR compliance."
        "Negative: Build complexity, WASM size overhead."
        "Mitigation: Use aggressive optimization flags, lazy-load WASM."))

      (adr-003
       (status accepted)
       (date "2026-01-24")
       (title "Manifest v3 for browser extension")
       (context
        "Chrome/Firefox require Manifest v3 for new extensions."
        "v2 is deprecated and will be removed.")
       (decision
        "Use Manifest v3 with service worker background script.")
       (consequences
        "Positive: Future-proof, official requirement."
        "Negative: More restrictive than v2, no persistent background page."
        "Mitigation: Use chrome.storage for state persistence."))

      (adr-004
       (status accepted)
       (date "2026-01-24")
       (title "Deno for build tooling")
       (context
        "RSR bans Node.js, npm, pnpm, yarn, bun."
        "Need a runtime for build scripts and tooling.")
       (decision
        "Use Deno for all build scripts and dev tooling."
        "Use esbuild (Deno-compatible) for bundling.")
       (consequences
        "Positive: RSR compliance, built-in TypeScript/JSX, secure by default."
        "Negative: Some tools expect Node/npm."
        "Mitigation: Use Deno-compatible alternatives or shell out to native tools."))

      (adr-005
       (status proposed)
       (date "2026-01-24")
       (title "Platform adapter strategy")
       (context
        "Each platform (YouTube, X, Instagram, TikTok) has different DOM structure."
        "Need maintainable way to handle platform-specific code.")
       (decision
        "Create platform adapter modules in src/platforms/."
        "Each adapter implements standard interface: detectPlatform, extractSignals, applyTransform."
        "Use strategy pattern to select adapter at runtime.")
       (consequences
        "Positive: Separation of concerns, easy to add new platforms."
        "Negative: Each platform requires reverse-engineering DOM."
        "Mitigation: Start with one platform (YouTube), iterate."))

      (adr-006
       (status proposed)
       (date "2026-01-24")
       (title "User consent for all automated actions")
       (context
        "Extension will perform automated clicks, scrolls, tab opens."
        "Risk of unintended consequences or user distrust.")
       (decision
        "All automated actions require explicit user consent."
        "Rate limiting enforced by default."
        "Clear activity log with undo where possible."
        "Narrative explanations for every action.")
       (consequences
        "Positive: User trust, transparency, safety."
        "Negative: More friction, can't be fully automated."
        "Mitigation: Make consent process smooth, allow 'always allow' for trusted rules."))

      (adr-007
       (status accepted)
       (date "2026-01-24")
       (title "Hybrid Ephapax/Rust architecture (incremental adoption)")
       (context
        "Rule engine performance could be improved via Ephapax's linear types and region-based memory."
        "Ephapax offers 1.8-3× speedup potential via O(1) bulk deallocation and Coq-proven memory safety."
        "However, complete rewrite is high-risk and takes 9+ months."
        "Ephapax is early-stage (stdlib still planned)."
        "Current Rust implementation works (180KB WASM, 5ms/rule).")
       (decision
        "v1.0: Ship pure Rust implementation, collect performance metrics."
        "v2.0: Hybrid approach - rewrite ONLY hot paths (20%) in Ephapax, keep Rust for glue (80%)."
        "Profile-guided optimization: rewrite only proven bottlenecks (condition evaluation, action generation)."
        "v5.0+: Evaluate full rewrite only if metrics justify it AND Ephapax stdlib is mature."
        "Integration: Package with Cerro Torre (.ctp), run in Vörðr containers, validate via Svalinn gateway.")
       (consequences
        "Positive: Low-risk incremental adoption, 1.8× speedup for 2 months work, Coq proofs for critical paths."
        "Positive: Deepest formal verification stack (SPARK + Coq + Idris2 + Idris2)."
        "Positive: 20% smaller WASM (140KB vs 180KB), 75% less memory per container (64MB vs 256MB)."
        "Negative: FFI overhead (~0.1ms per boundary), team must learn linear types."
        "Negative: Ephapax ecosystem immature (stdlib planned, but not ready)."
        "Mitigation: Use right tool for each job - Ephapax for tight loops, Rust for FFI/I/O/serialization."
        "Mitigation: Incremental learning - start with 3 rules, expand as team gains fluency."))

      (adr-008
       (status accepted)
       (date "2026-01-24")
       (title "Integration with Svalinn/Vörðr/Cerro Torre verified container stack")
       (context
        "Browser extension sandbox provides basic isolation but no formal guarantees."
        "Svalinn (edge gateway), Vörðr (container runtime), Cerro Torre (provenance builder) are existing hyperpolymath repos."
        "Stack provides formal verification: SPARK (Cerro Torre), Idris2 (Vörðr), Coq (Ephapax)."
        "Could improve security, dependability, and enterprise adoption.")
       (decision
        "v2.0: Package WASM with Cerro Torre (.ctp bundles) for cryptographic provenance."
        "v2.0 (Enterprise): Optional Svalinn gateway for policy enforcement, OAuth2/SSO integration."
        "v5.0: Run WASM in Vörðr containers for Idris2-proven state transitions and reversibility."
        "Bundle Coq proofs with .ctp for mathematical verification of memory safety.")
       (consequences
        "Positive: Cryptographic provenance (threshold signing, reproducible builds)."
        "Positive: Formal verification stack (SPARK crypto + Coq memory + Idris2 states)."
        "Positive: Enterprise compliance (policy enforcement, audit logs, SSO)."
        "Positive: BEAM fault tolerance (Elixir supervision trees) for crash recovery."
        "Positive: Bennett-reversible operations (rollback bad rules)."
        "Negative: 10-20% performance overhead (IPC + verification)."
        "Negative: Increased complexity (3-layer stack vs simple extension)."
        "Mitigation: Make containerization optional (v1.0 works standalone, v2.0+ adds container support)."
        "Mitigation: Enterprise features justify overhead (SMB/enterprise market)."))

      (adr-009
       (status proposed)
       (date "2026-01-24")
       (title "Profile-guided optimization over premature optimization")
       (context
        "Performance optimization should be data-driven."
        "Don't know which operations are actually slow until measured in production."
        "80/20 rule: 20% of code accounts for 80% of runtime.")
       (decision
        "v1.0: Ship MVP, instrument for performance metrics (timing, memory, WASM size)."
        "Collect 3+ months of real-world data before optimizing."
        "Identify top 3 slowest operations via profiling."
        "Optimize only proven bottlenecks (profile-guided, not speculation-driven)."
        "Benchmark all optimizations (must show ≥30% improvement to justify).")
       (consequences
        "Positive: Data-driven decisions, avoid wasted effort on non-bottlenecks."
        "Positive: Focus engineering time on user-visible improvements."
        "Negative: Can't claim 'fastest' from day one."
        "Mitigation: Current Rust perf is 'good enough' for v1.0, optimize later based on data."))))

    (development-practices
     (code-style
      "ReScript: Follow official style guide, 2-space indent."
      "Rust: rustfmt with default settings."
      "JS glue: Minimal, follow Deno lint rules.")

     (security
      "Never exfiltrate user data."
      "All network requests user-visible and consentual."
      "Rate limiting on all automated actions."
      "Sandbox untrusted content.")

     (testing
      "Unit tests for ReScript modules (planned)."
      "Rust tests for rule engine logic."
      "Manual testing in Chrome for extension behavior.")

     (versioning
      "Semantic versioning: MAJOR.MINOR.PATCH."
      "0.x.x = pre-1.0, breaking changes allowed.")

     (documentation
      "README.adoc for overview and quickstart."
      "Inline comments for complex logic."
      "STATE.scm for current progress."
      "ECOSYSTEM.scm for project relationships.")

     (branching
      "main branch = stable releases."
      "develop branch = integration (planned)."
      "Feature branches for new work."))

    (design-rationale
     (why-minikaren
      "Logic programming is a natural fit for declarative rules."
      "Minikaren is elegant, small, and embeddable."
      "Rust implementation gives performance + type safety.")

     (why-personas
      "Behavioral polymorphism requires stable alternate identities."
      "Personas are human-understandable abstractions."
      "Easier to narrate than raw parameter tuning.")

     (why-lenses
      "Lenses provide high-level, composable transformations."
      "Easier to understand than algorithmic details."
      "Maps to optical/perceptual metaphor.")

     (why-membrane-metaphor
      "Membranes are differentially permeable = selective filtering."
      "Thickness = degree of intervention."
      "Crossing = intentional context shift."
      "Biologically grounded, resonates with living systems.")

     (why-narratable
      "Opacity creates distrust."
      "Users must understand what the tool is doing."
      "Narrative = explanation + rationale + consequence."
      "Aligns with governance-design principles."))))
