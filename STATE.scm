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
     (phase "scaffold-complete")
     (overall-completion 15)
     (components
      ((name "ReScript Core")
       (completion 30)
       (status "foundational-modules-written"))
      ((name "Rust Rule Engine")
       (completion 40)
       (status "minikaren-core-implemented"))
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
      ("Project structure" "ReScript modules" "Rust WASM engine skeleton"
       "Popup UI mockup" "Build scripts"))

     (not-yet-working
      ("ReScript compilation" "WASM integration" "Platform-specific DOM hooks"
       "Chrome extension loading" "Lens transformations" "Persona behavior")))

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

    (blockers-and-issues
     (critical
      ("Need to install ReScript compiler and test compilation"
       "Need to install wasm-pack and test Rust build"
       "Rust code uses `rand` crate without dependency declaration"))

     (high
      ("Browser extension bindings for ReScript not written"
       "Platform-specific DOM selectors unknown"
       "WASM integration pattern needs testing"))

     (medium
      ("Icon assets not created (16px, 48px, 128px)"
       "Activity log UI not designed"
       "Control panel (panel.html) not implemented"))

     (low
      ("No tests written"
       "No CI/CD workflows"
       "Documentation needs examples")))

    (critical-next-actions
     (immediate
      ("Fix Rust Cargo.toml: add `rand` dependency"
       "Test ReScript compilation: `npx rescript build`"
       "Test Rust build: `cargo build --target wasm32-unknown-unknown`"
       "Create placeholder icon assets"))

     (this-week
      ("Write browser extension bindings in ReScript"
       "Implement basic YouTube platform adapter"
       "Test extension loading in Chrome"
       "Fix any build errors"))

     (this-month
      ("Implement Observer.extractSignals for YouTube"
       "Build Random Walk lens transformation logic"
       "Integrate WASM rule engine"
       "Create activity log UI")))

    (session-history
     ((session-id "2026-01-24-scaffold")
      (date "2026-01-24")
      (accomplishments
       ("Created full project structure"
        "Implemented ReScript modules: Membrane, Observer, Actuator, Lens, Persona"
        "Implemented Rust Minikaren rule engine (rules, context, actions)"
        "Created popup UI (HTML/CSS/JS)"
        "Wrote build scripts (Deno)"
        "Wrote comprehensive README.adoc"
        "Created STATE.scm"))
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
