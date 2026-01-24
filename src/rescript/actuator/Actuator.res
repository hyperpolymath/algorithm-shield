// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 hyperpolymath
// Part of Algorithm Shield - https://github.com/hyperpolymath/algorithm-shield
// Actuator module: Performs controlled interactions to perturb algorithms

module InteractionType = {
  type t =
    | Click(string) // CSS selector or element
    | Scroll(int) // Pixels
    | Hover(string)
    | OpenTab(string) // URL
    | CloseTab
    | Search(string)
    | Wait(int) // Milliseconds
}

module SafetyBounds = {
  type t = {
    maxClicksPerMinute: int,
    maxTabsOpen: int,
    maxScrollPerSecond: int,
    userConsentRequired: bool,
  }

  let default = {
    maxClicksPerMinute: 10,
    maxTabsOpen: 5,
    maxScrollPerSecond: 2000,
    userConsentRequired: true,
  }
}

module ActionLog = {
  type entry = {
    action: InteractionType.t,
    timestamp: float,
    rationale: string,
    reversible: bool,
  }

  type t = array<entry>

  let empty: t = []

  let add = (log: t, action: InteractionType.t, rationale: string): t => {
    let entry = {
      action,
      timestamp: Date.now(),
      rationale,
      reversible: false, // Set appropriately per action
    }
    Array.concat(log, [entry])
  }

  let narrate = (entry: entry): string => {
    let actionStr = switch entry.action {
    | Click(selector) => `Clicked ${selector}`
    | Scroll(px) => `Scrolled ${Int.toString(px)}px`
    | Hover(selector) => `Hovered ${selector}`
    | OpenTab(url) => `Opened tab: ${url}`
    | CloseTab => "Closed tab"
    | Search(query) => `Searched: ${query}`
    | Wait(ms) => `Waited ${Int.toString(ms)}ms`
    }

    `${actionStr} - ${entry.rationale}`
  }
}

// Rate limiting state
module RateLimiter = {
  type t = {
    recentActions: array<float>, // Timestamps
    bounds: SafetyBounds.t,
  }

  let create = (bounds: SafetyBounds.t): t => {
    {recentActions: [], bounds}
  }

  let canAct = (limiter: t, _actionType: InteractionType.t): bool => {
    let now = Date.now()
    let oneMinuteAgo = now -. 60000.0

    // Filter to actions in last minute
    let recentCount = limiter.recentActions
      ->Array.filter(ts => ts > oneMinuteAgo)
      ->Array.length

    recentCount < limiter.bounds.maxClicksPerMinute
  }

  let recordAction = (limiter: t): t => {
    let now = Date.now()
    let oneMinuteAgo = now -. 60000.0

    // Keep only recent actions and add new one
    let filtered = limiter.recentActions->Array.filter(ts => ts > oneMinuteAgo)
    {
      ...limiter,
      recentActions: Array.concat(filtered, [now]),
    }
  }
}

// Execute interaction with safety checks
let executeInteraction = (
  action: InteractionType.t,
  rationale: string,
  limiter: RateLimiter.t,
  log: ActionLog.t,
): result<(RateLimiter.t, ActionLog.t), string> => {
  if !RateLimiter.canAct(limiter, action) {
    Error("Rate limit exceeded")
  } else {
    // Actual DOM manipulation would happen here
    // For now, just record the action
    let newLimiter = RateLimiter.recordAction(limiter)
    let newLog = ActionLog.add(log, action, rationale)
    Ok((newLimiter, newLog))
  }
}
