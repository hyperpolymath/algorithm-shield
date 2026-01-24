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
        "Mitigation: Make consent process smooth, allow 'always allow' for trusted rules."))))

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
