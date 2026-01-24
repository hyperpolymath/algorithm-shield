# Algorithm Shield - Architecture Overview

**Quick Reference**: Key architectural decisions and technology stack

---

## Strategic Direction (User-Approved ✅)

**Hybrid Architecture**: ReScript + Rust + Ephapax (incremental adoption)

**Not a complete rewrite** - Profile-guided optimization of hot paths only

**Integration**: Svalinn/Vörðr/Cerro Torre verified container stack (v2.0+)

---

## Version Roadmap

### v1.0 (Jun 2026) - Pure Rust MVP ✅

**Goal**: Ship production-ready browser extension

**Tech Stack**:
- ReScript: UI, state management, browser API bindings
- Rust/WASM: Rule engine (180KB, 5ms/rule)
- Deno: Build tooling

**Focus**: Prove core concept, collect performance metrics

---

### v2.0 (Dec 2026) - Hybrid + Containerization

**Goal**: Performance optimization + enterprise features

**Tech Stack**:
- ReScript: UI (no change)
- Rust: FFI, serialization, I/O (80% of codebase)
- **Ephapax**: Hot paths only - condition evaluation, action generation (20% of codebase)
- **Cerro Torre**: Package WASM as .ctp bundles (cryptographic provenance)
- **Svalinn** (Enterprise): Edge gateway for policy enforcement, OAuth2/SSO
- **Vörðr** (v5.0+): Container runtime for formal verification

**Performance Targets**:
- 1.8× faster rule evaluation (Ephapax regions)
- 140KB WASM (down from 180KB)
- 64MB memory per container (down from 256MB)

**Formal Verification Stack**:
```
Layer 4: SPARK (Cerro Torre)  - Cryptographic operations proven
Layer 3: Coq (Ephapax)        - Memory safety proven (no use-after-free, no leaks)
Layer 2: Idris2 (Ephapax)     - Linear types enforce affine constraints
Layer 1: Idris2 (Vörðr)       - Container state transitions proven
```

**Deliverables**:
1. Profile production metrics (3 months)
2. Identify top 3 bottlenecks
3. Rewrite only hot paths in Ephapax (2 months)
4. Package with Cerro Torre (.ctp bundles)
5. Optional Svalinn gateway for enterprise

---

### v5.0 (Jun 2027) - Full Containerization

**Goal**: Production deployment in Vörðr containers

**New Features**:
- Vörðr container runtime (Elixir/Rust/Idris2/SPARK)
- Bennett-reversible operations (rollback bad rules)
- BEAM fault tolerance (auto-restart crashed containers)
- Parallel rule evaluation (10-12× speedup for 500+ rules)
- Federated bubble map (crowdsourced topology)

**Decision Point (Dec 2026)**:
- If hybrid approach meets needs → stay hybrid
- If users complain about speed → expand Ephapax usage
- If enterprise demands formal verification → increase Coq coverage

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **UI** | ReScript | Popup, control panel, state management |
| **Browser APIs** | ReScript bindings | chrome.storage, chrome.tabs, chrome.runtime |
| **Glue Layer** | Rust | JSON serialization, FFI coordination, storage |
| **Hot Paths** | Ephapax (v2.0+) | Condition evaluation, action generation |
| **Cold Paths** | Rust | Everything else (I/O, FFI, serialization) |
| **Build** | Deno | Build scripts, bundling (no Node/npm/bun per RSR) |
| **Packaging** | Cerro Torre (v2.0+) | .ctp bundles with provenance |
| **Gateway** | Svalinn (v2.0+ Enterprise) | Policy enforcement, OAuth2/SSO |
| **Runtime** | Vörðr (v5.0+) | Formal verification, reversibility |

---

## Component Distribution (v2.0 Target)

```
┌────────────────────────────────────────────────────────────┐
│              Algorithm Shield (Hybrid)                      │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  ReScript (UI & Orchestration)                    ~40KB    │
│  ├─ Popup UI                                               │
│  ├─ State management                                       │
│  └─ Browser API bindings                                   │
│                                                             │
│  Rust WASM (Glue Layer)                           ~60KB    │
│  ├─ JSON serialization (serde)                             │
│  ├─ FFI coordination (wasm-bindgen)                        │
│  ├─ Storage integration                                    │
│  └─ Non-critical rule processing                           │
│                                                             │
│  Ephapax WASM (Performance-Critical Core)         ~80KB    │
│  ├─ Condition evaluation (tight loops)            ✅       │
│  ├─ Action generation (region-based)              ✅       │
│  ├─ Pattern matching (miniKaren unification)      ✅       │
│  └─ Coq-proven correctness                        📊       │
│                                                             │
│  Total WASM:                                      ~140KB   │
│  (down from 180KB pure Rust)                               │
└────────────────────────────────────────────────────────────┘
```

---

## Performance Comparison

| Metric | v1.0 (Rust) | v2.0 (Hybrid) | v5.0+ (Vörðr) |
|--------|-------------|---------------|---------------|
| Single rule eval | 5ms | 3ms (1.67×) | 3ms |
| 100 rules batch | 500ms | 300ms (1.67×) | 45ms (11×) |
| WASM size | 180KB | 140KB (-22%) | 120KB (-33%) |
| Memory/container | 256MB | 64MB (-75%) | 64MB |
| Formal verification | None | Coq (hot paths) | SPARK+Coq+Idris2 |

---

## Formal Guarantees (v2.0+)

### Coq-Proven (Ephapax Core)

From `ephapax/formal/*.v`:

1. **Type Soundness**: Well-typed programs don't crash (Progress + Preservation theorems)
2. **No Use-After-Free**: Linear values cannot be accessed after consumption
3. **No Memory Leaks**: All linear values must be consumed exactly once
4. **Region Safety**: Region deallocation cannot create dangling pointers

### SPARK-Proven (Cerro Torre Packaging)

From `cerro-torre/src/core/*.adb`:

1. **Cryptographic Correctness**: SHA-256, Ed25519 signatures (FIPS 180-4, RFC 8032)
2. **No Integer Overflow**: All arithmetic proven safe
3. **No Buffer Overruns**: Array accesses proven in-bounds

### Idris2-Proven (Vörðr Runtime, v5.0+)

1. **State Transition Correctness**: Container lifecycle proven valid
2. **Reversibility**: All operations can be undone (Bennett's theorem)

---

## Key Architectural Decisions (ADRs)

See `META.scm` for full ADRs. Summary:

- **ADR-001**: ReScript for application logic (type safety, RSR compliance)
- **ADR-002**: Rust/WASM for rule engine (performance, WASM target)
- **ADR-003**: Manifest v3 (future-proof, official requirement)
- **ADR-004**: Deno for build tooling (RSR compliance, no Node/npm)
- **ADR-007**: ✅ **Hybrid Ephapax/Rust** (incremental, profile-guided, not complete rewrite)
- **ADR-008**: ✅ **Integration with Svalinn/Vörðr/Cerro Torre** (formal verification stack)
- **ADR-009**: ✅ **Profile-guided optimization** (data-driven, 80/20 rule)

---

## Migration Strategy

### Phase 1: Production Metrics (v1.0 - Jun 2026)

Ship pure Rust, instrument for metrics:
- Rule evaluation timing
- Memory usage
- WASM size
- User-reported performance issues

Collect 3+ months of data.

---

### Phase 2: Hot Path Identification (v2.0 - Sep 2026)

Profile production data, identify bottlenecks:
- Top 3 slowest operations
- Memory allocation hot spots
- CPU-intensive loops

Expected hot paths:
1. Condition evaluation (tight loops, heavy allocation)
2. Action generation (many small objects)
3. Pattern matching (recursive algorithms)

---

### Phase 3: Incremental Rewrite (v2.0 - Oct-Nov 2026)

Rewrite ONLY proven bottlenecks in Ephapax:
- Month 1: Condition evaluator (Ephapax)
- Month 2: Action generator (Ephapax)
- Benchmark: Must show ≥30% improvement

Keep everything else in Rust.

---

### Phase 4: Containerization (v2.0 - Dec 2026)

Package with verified container stack:
- Cerro Torre: .ctp bundles with provenance
- Svalinn (optional): Enterprise policy gateway
- Deploy hybrid WASM (140KB)

---

### Phase 5: Full Verification (v5.0 - Jun 2027)

If justified by metrics:
- Vörðr container runtime
- Parallel rule evaluation
- Complete formal verification chain

---

## Development Workflow

```bash
# 1. Develop ReScript UI
cd src/rescript
npx rescript build

# 2. Develop Rust glue layer
cd src/rust
cargo build --release --target wasm32-wasi

# 3. Develop Ephapax hot paths (v2.0+)
cd src/ephapax
ephapax-cli compile-affine rule_engine.eph -o rule_engine.wasm

# 4. Bundle all WASM
cd ../..
deno run build.ts

# 5. Package with Cerro Torre (v2.0+)
ct pack dist/algorithm_shield_engine.wasm \
  -o algorithm-shield.ctp \
  --sign-with keyring.asc

# 6. Test in browser
# Load dist/ as unpacked extension in chrome://extensions
```

---

## Integration Points

### ReScript ↔ Rust

```rescript
// ReScript side
@module("../wasm/algorithm_shield_engine.js")
external evaluateRule: (string, string) => promise<string> = "evaluate_rule"

let result = await evaluateRule(ruleJson, contextJson)
```

```rust
// Rust side
#[wasm_bindgen]
pub fn evaluate_rule(rule_json: &str, context_json: &str) -> String {
    // Deserialize, call Ephapax hot path, serialize result
}
```

---

### Rust ↔ Ephapax (v2.0+)

```rust
// Rust wrapper
extern "C" {
    fn ephapax_evaluate_conditions(
        conditions: *const Condition,
        len: usize,
        context: *const Context
    ) -> *const Action;
}

pub fn evaluate_rule(rule: &Rule, context: &Context) -> Vec<Action> {
    unsafe {
        let actions_ptr = ephapax_evaluate_conditions(
            rule.conditions.as_ptr(),
            rule.conditions.len(),
            context as *const Context
        );
        ptr_to_vec(actions_ptr)
    }
}
```

```ephapax
-- Ephapax hot path
extern "C" fn ephapax_evaluate_conditions(...) -> *const Action {
    region r {
        let! result = evaluate@r(conditions, context) in
        to_raw_ptr(result)
    }
    -- Region exits: O(1) cleanup
}
```

---

## Security Boundaries

```
┌────────────────────────────────────────────────────┐
│         Browser Sandbox (built-in)                  │
│  ┌──────────────────────────────────────────────┐  │
│  │  Extension Process (Manifest v3)             │  │
│  │  ┌────────────────────────────────────────┐  │  │
│  │  │  WASM Sandbox (compile-time memory)    │  │  │
│  │  │  ┌──────────────────────────────────┐  │  │  │
│  │  │  │ Svalinn Container (v2.0+)        │  │  │  │
│  │  │  │ ┌──────────────────────────────┐ │  │  │  │
│  │  │  │ │ Vörðr Container (v5.0+)      │ │  │  │  │
│  │  │  │ │ - Idris2 proven transitions  │ │  │  │  │
│  │  │  │ │ - BEAM fault tolerance       │ │  │  │  │
│  │  │  │ │ - eBPF syscall monitoring    │ │  │  │  │
│  │  │  │ └──────────────────────────────┘ │  │  │  │
│  │  │  └──────────────────────────────────┘  │  │  │
│  │  └────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────┘
```

**Defense in Depth**: 5 layers of isolation (v5.0+)

---

## Documentation

- `README.adoc` - Project overview
- `docs/SEAM-ANALYSIS.adoc` - Integration point analysis
- `docs/ROADMAP.adoc` - Version evolution plan
- `docs/DEFENSE-LAYERS.adoc` - OSI layer security analysis
- `docs/COMPETITIVE-LANDSCAPE.adoc` - Comparison with existing tools
- `docs/NETWORK-PROTOCOLS.adoc` - IPv6, QUIC, HTTP/3, SPARK integration
- `docs/CONTAINERIZATION-ANALYSIS.adoc` - Svalinn/Vörðr/Cerro Torre integration
- `docs/EPHAPAX-PERFORMANCE.adoc` - Performance benchmarks, Coq proofs
- `docs/EPHAPAX-MIGRATION-STRATEGY.adoc` - Incremental adoption plan
- `STATE.scm` - Current project state
- `META.scm` - Architecture decision records (ADRs)
- `ECOSYSTEM.scm` - Position in hyperpolymath ecosystem

---

## Repository

**GitHub**: https://github.com/hyperpolymath/algorithm-shield

**Status**: Early development (v0.1), 35% complete

**License**: AGPL-3.0-or-later

---

## Key Insight

**The membrane operates at every layer - but not every layer needs Ephapax.**

Use the right tool for each job:
- **ReScript**: User interface (type-safe, functional, React-like)
- **Rust**: FFI, I/O, serialization (mature ecosystem, excellent tooling)
- **Ephapax**: Performance-critical cores (linear types, regions, Coq proofs)

**80/20 rule**: 20% of code (hot paths) accounts for 80% of runtime.

Optimize the 20% that matters, keep the 80% simple.

---

_Last updated: 2026-01-24_
