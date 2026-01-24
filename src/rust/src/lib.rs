// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 hyperpolymath
// Part of Algorithm Shield - https://github.com/hyperpolymath/algorithm-shield
// WASM entry point for Algorithm Shield rule engine
// Uses proven library for unbreakable JSON parsing

use wasm_bindgen::prelude::*;
use serde::{Deserialize, Serialize};
use proven::{SafeJson, SafeString};

mod minikaren;

#[wasm_bindgen]
pub struct RuleEngine {
    rules: Vec<minikaren::Rule>,
}

#[wasm_bindgen]
impl RuleEngine {
    #[wasm_bindgen(constructor)]
    pub fn new() -> Self {
        RuleEngine { rules: Vec::new() }
    }

    pub fn add_rule(&mut self, rule_json: &str) -> Result<(), JsValue> {
        // Use proven SafeJson for crash-proof parsing
        let rule: minikaren::Rule = SafeJson::parse(rule_json)
            .map_err(|e| JsValue::from_str(&format!("JSON parse error: {}", e)))?;
        self.rules.push(rule);
        Ok(())
    }

    pub fn evaluate(&self, context_json: &str) -> Result<String, JsValue> {
        // Use proven SafeJson for crash-proof parsing
        let context: minikaren::Context = SafeJson::parse(context_json)
            .map_err(|e| JsValue::from_str(&format!("JSON parse error: {}", e)))?;

        let actions = minikaren::evaluate_rules(&self.rules, &context);

        // Use proven SafeJson for crash-proof serialization
        SafeJson::stringify(&actions)
            .map_err(|e| JsValue::from_str(&format!("JSON serialize error: {}", e)))
    }

    pub fn narrate_rules(&self) -> String {
        self.rules
            .iter()
            .map(|r| format!("• {}", r.narrate()))
            .collect::<Vec<_>>()
            .join("\n")
    }
}

#[wasm_bindgen(start)]
pub fn main() {
    #[cfg(feature = "console_error_panic_hook")]
    console_error_panic_hook::set_once();
}
