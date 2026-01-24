;; STATE.scm - Current project state for Algorithm Shield
;; Media Type: application/vnd.state+scm

(define state
  '((metadata
     (version "0.1.0")
     (schema-version "1.0")
     (created "2026-01-24")
     (updated "2026-01-24")
     (project "algorithm-shield")
     (repo "https://github.com/hyperpolymath/algorithm-shield"))

    (project-context
     (name "Algorithm Shield")
     (tagline "Programmable membrane for crossing filter-bubble walls")
     (tech-stack
      ("ReScript" "Rust/WASM" "Deno" "Browser Extension API"))
     (domain "browser-extension" "counter-algorithm" "privacy-tool"))

    (current-position
     (phase "seam-2-closed")
     (overall-completion 25)
     (components
      ((name "ReScript Core")
       (completion 40)
       (status "compiled-with-browser-bindings"))
      ((name "Rust Rule Engine")
       (completion 80)
       (status "built-to-wasm-180kb"))
      ((name "UI/UX")
       (completion 20)
       (status "popup-html-css-complete"))
      ((name "Build System")
       (completion 50)
       (status "build-scripts-ready-untested"))
      ((name "Platform Adapters")
       (completion 0)
       (status "not-started"))))

     (working-features
      ("Project structure" "ReScript compilation" "Rust WASM build (180KB)"
       "Browser API bindings (Chrome Storage/Tabs/Runtime)" "Rule engine WASM exports"
       "Popup UI mockup" "Build scripts"))

     (not-yet-working
      ("Platform-specific DOM hooks" "Chrome extension loading (untested)"
       "Lens transformations (stubbed)" "Persona behavior (stubbed)"
       "Actual WASM integration test in browser" "Extension manifest icons")))

    (route-to-mvp
     (milestones
      ((name "Phase 1: Working Build")
       (target-date "2026-01-31")
       (items
        ("Compile ReScript without errors"
         "Build Rust WASM successfully"
         "Load extension in Chrome"
         "Popup displays and state persists")))

      ((name "Phase 2: Observer Basics")
       (target-date "2026-02-14")
       (items
        ("Detect platform (YouTube/X)"
         "Extract basic content signals from feed"
         "Display feed diversity in popup"
         "Simple bubble map visualization")))

      ((name "Phase 3: First Lens")
       (target-date "2026-02-28")
       (items
        ("Implement Random Walk lens"
         "Generate off-distribution URLs"
         "Trigger membrane breach action"
         "Log actions to activity log")))

      ((name "Phase 4: Rule Engine Integration")
       (target-date "2026-03-15")
       (items
        ("Load WASM module in extension"
         "Evaluate Minikaren rules against context"
         "Execute actions from rule engine"
         "Display rule narratives in UI")))))

    (critical-seams
     ;; See docs/SEAM-ANALYSIS.adoc for full analysis
     ((seam-1
       (name "ReScript ↔ Browser APIs")
       (risk "MEDIUM")
       (status "unresolved")
       (blocker "No bindings written for chrome.storage, chrome.tabs, chrome.runtime")
       (required-for "v0.5"))

      (seam-2
       (name "ReScript ↔ Rust/WASM")
       (risk "HIGH")
       (status "CLOSED")
       (resolution "WASM built (180KB), ReScript bindings created, async loading ready")
       (closed-date "2026-01-24")
       (required-for "v0.5"))

      (seam-3
       (name "Content Script ↔ Page DOM")
       (risk "CRITICAL")
       (status "unresolved")
       (blocker "No platform adapters implemented, DOM selectors unknown")
       (required-for "v0.5"))

      (seam-6
       (name "Actuator ↔ Platform Detection")
       (risk "CRITICAL")
       (status "unresolved")
       (blocker "No bot detection mitigation, timing not human-like")
       (required-for "v0.5"))))

    (blockers-and-issues
     (critical
      ("SEAM-2: WASM integration completely untested"
       "SEAM-3: YouTube DOM structure unmapped"
       "SEAM-6: Bot detection will trigger on first use"
       "Need to install ReScript compiler and test compilation"
       "Need to install wasm-pack and test Rust build"))

     (high
      ("SEAM-1: Browser extension bindings for ReScript not written"
       "Platform-specific DOM selectors unknown"
       "WASM size could exceed 500KB (performance risk)"
       "No human-like timing implemented"))

     (medium
      ("Icon assets not created (16px, 48px, 128px)"
       "Activity log UI not designed"
       "Control panel (panel.html) not implemented"
       "Missing NEUROSYM.scm, PLAYBOOK.scm, AGENTIC.scm (3/6 SCM complete)"))

     (low
      ("No tests written"
       "No CI/CD workflows"
       "Documentation needs examples")))

    (critical-next-actions
     ;; Path to v0.5 (8 weeks): Close seams 2, 3, 6
     (immediate
      ("Read seam analysis: docs/SEAM-ANALYSIS.adoc"
       "Install ReScript: npm install -g rescript"
       "Test ReScript compilation: npx rescript build"
       "Install wasm-pack for Rust→WASM"
       "Create placeholder icon assets (16/48/128 px)"))

     (this-week
      ("SEAM-2: Build Rust→WASM with wasm-pack"
       "SEAM-2: Test WASM loads in extension context"
       "SEAM-1: Write ChromeStorage.res bindings"
       "SEAM-1: Write ChromeTabs.res bindings"
       "Test extension loads in Chrome without errors"))

     (this-month
      ("SEAM-3: Map YouTube feed DOM structure"
       "SEAM-3: Implement YouTubeAdapter.extractSignals"
       "SEAM-6: Implement human-like timing (jitter, delays)"
       "SEAM-6: Test bot detection resilience"
       "Implement Random Walk lens URL generation"
       "Wire popup UI to ReScript state"))

     (v0.5-milestone
      ("Extension loads and displays popup"
       "YouTube feed diversity calculated"
       "Membrane breach opens 3-5 tabs with human timing"
       "Activity log records all actions"
       "State persists across browser sessions"
       "User testing with 5-10 people")))

    (version-roadmap
     ;; See docs/ROADMAP.adoc for full details
     ((v0.5
       (target-date "2026-03-15")
       (goal "First working prototype")
       (features "YouTube observer, Random Walk lens, manual breach")
       (critical-seams "2, 3, 6"))

      (v1.0
       (target-date "2026-06-01")
       (goal "Production MVP")
       (features "3 platforms, 5 lenses, 3 personas, rule engine")
       (critical-seams "7, 8, 9, 10"))

      (v2.0
       (target-date "2026-12-01")
       (goal "Distributed personas")
       (features "Persona sync, encrypted export, marketplace"))

      (v5.0
       (target-date "2027-06-01")
       (goal "Federated bubble map")
       (features "Crowdsourced topology, community lenses"))

      (v10.0
       (target-date "2028-01-01")
       (goal "Ecosystem standard")
       (features "W3C protocol, browser-native, platform cooperation"))))

    (session-history
     ((session-id "2026-01-24-seam-2-closed")
      (date "2026-01-24")
      (accomplishments
       ("CLOSED Seam 2: ReScript ↔ Rust/WASM integration"
        "Installed ReScript compiler (npm)"
        "Fixed ReScript compilation errors (6 files, 62 modules)"
        "Installed wasm-pack"
        "Built Rust → WASM successfully (180KB, under target)"
        "Created ReScript bindings: RuleEngine, ChromeStorage, ChromeTabs, ChromeRuntime"
        "Created WASM integration test file"
        "Fixed deprecated Array.sliceToEnd → Array.slice"
        "Fixed @scope syntax for browser API bindings"
        "Updated STATE.scm: 15% → 25% complete"))
      (duration-minutes 45)
      (files-created 6)
      (seams-closed 1))

     (session-id "2026-01-24-seam-analysis")
      (date "2026-01-24")
      (accomplishments
       ("Performed comprehensive seam analysis (10 critical interfaces)"
        "Mapped evolutionary roadmap v0.1→v0.5→v1.0→v10.0"
        "Documented all critical integration points"
        "Identified 4 critical seams for v0.5 (2, 3, 6, and 1)"
        "Created docs/SEAM-ANALYSIS.adoc (detailed)"
        "Created docs/ROADMAP.adoc (version plan)"
        "Updated STATE.scm with seam tracking"
        "Stored 6SCM specification in memory"))
      (duration-minutes 60)
      (files-created 2))

     (session-id "2026-01-24-scaffold")
      (date "2026-01-24")
      (accomplishments
       ("Created full project structure"
        "Implemented ReScript modules: Membrane, Observer, Actuator, Lens, Persona"
        "Implemented Rust Minikaren rule engine (rules, context, actions)"
        "Created popup UI (HTML/CSS/JS)"
        "Wrote build scripts (Deno)"
        "Wrote comprehensive README.adoc"
        "Created STATE.scm, META.scm, ECOSYSTEM.scm (3/6 SCM)"))
      (duration-minutes 90)
      (files-created 25)))))

;; Helper functions
(define (get-completion-percentage component-name)
  (let ((components (cdr (assoc 'components (cdr (assoc 'current-position state))))))
    (let ((component (assoc 'name components)))
      (if component
          (cdr (assoc 'completion component))
          0))))

(define (get-blockers severity)
  (cdr (assoc severity (cdr (assoc 'blockers-and-issues state)))))

(define (get-milestone name)
  (let ((milestones (cdr (assoc 'milestones (cdr (assoc 'route-to-mvp state))))))
    (filter (lambda (m) (equal? (cdr (assoc 'name m)) name)) milestones)))
