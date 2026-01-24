// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 hyperpolymath
// Part of Algorithm Shield - https://github.com/hyperpolymath/algorithm-shield
// Lens module: Transform and reorder feeds based on selected perspective

open Observer

module LensConfig = {
  type t = {
    name: string,
    description: string,
    intensity: float, // 0.0 - 1.0
    parameters: Dict.t<JSON.t>,
  }
}

module TransformResult = {
  type action =
    | Reorder(array<int>) // New order of indices
    | Inject(array<string>) // URLs to inject
    | Hide(array<int>) // Indices to hide
    | Highlight(array<int>) // Indices to emphasize

  type t = {
    actions: array<action>,
    narrative: string,
  }
}

// Opposition Lens: Surface content unlike current distribution
let applyOppositionLens = (
  feedState: FeedState.t,
  config: LensConfig.t,
): TransformResult.t => {
  // Find underrepresented categories
  let allCategories = [
    ContentSignal.Tech,
    Politics,
    Art,
    Science,
    Entertainment,
    News,
    Social,
    Commerce,
    Education,
    Health,
  ]

  let dominantCats = feedState.dominantClusters->Array.map(c => c.category)

  // Categories NOT in dominant list
  let opposingCats = allCategories->Array.filter(cat =>
    !(dominantCats->Array.includes(cat))
  )

  let narrative = if Array.length(opposingCats) > 0 {
    "Surfacing content from underrepresented categories"
  } else {
    "Feed already diverse"
  }

  {
    actions: [], // Would generate actual inject/reorder actions
    narrative,
  }
}

// Random Walk Lens: Explore low-probability paths
let applyRandomWalkLens = (
  feedState: FeedState.t,
  config: LensConfig.t,
): TransformResult.t => {
  // Define diverse search queries outside typical bubbles
  let diverseTopics = [
    ("origami tutorials", ContentSignal.Art),
    ("mycology foraging", ContentSignal.Education),
    ("esperanto language", ContentSignal.Education),
    ("circuit bending music", ContentSignal.Entertainment),
    ("urban beekeeping", ContentSignal.Health),
    ("brutalist architecture", ContentSignal.Art),
    ("fermentation science", ContentSignal.Science),
    ("indigenous knowledge systems", ContentSignal.Education),
    ("mathematical art", ContentSignal.Art),
    ("permaculture design", ContentSignal.Health),
    ("linguistics documentary", ContentSignal.Education),
    ("avant-garde cinema", ContentSignal.Entertainment),
    ("ethnomusicology", ContentSignal.Entertainment),
    ("bio-architecture", ContentSignal.Science),
    ("systems thinking", ContentSignal.Education),
  ]

  // Find dominant categories to avoid
  let dominantCats = feedState.dominantClusters->Array.map(c => c.category)

  // Filter topics that are NOT in dominant categories
  let opposingTopics = diverseTopics->Array.filter(((_, cat)) =>
    !(dominantCats->Array.includes(cat))
  )

  // Randomly select 3-5 topics
  let numToSelect = Int.fromFloat(3.0 +. Random.float(3.0))  // 3-5
  let selectedTopics = []

  for _ in 0 to numToSelect - 1 {
    let availableTopics = if Array.length(opposingTopics) > 0 {
      opposingTopics
    } else {
      diverseTopics  // Fallback if all categories are dominant
    }

    let randomIdx = Int.fromFloat(
      Random.float(Int.toFloat(Array.length(availableTopics)))
    )

    switch availableTopics->Array.get(randomIdx) {
    | Some((topic, _)) => {
        let encodedTopic = topic
          ->String.replaceAll(" ", "+")
        let url = `https://www.youtube.com/results?search_query=${encodedTopic}`
        selectedTopics->Array.push(url)->ignore
      }
    | None => ()
    }
  }

  let narrative = switch Array.length(selectedTopics) {
  | 0 => "No random walk paths generated"
  | n => `Opening ${Int.toString(n)} exploratory paths outside your filter bubble`
  }

  {
    actions: [TransformResult.Inject(selectedTopics)],
    narrative,
  }
}

// Time-Shift Lens: Prioritize older or non-trending content
let applyTimeShiftLens = (
  feedState: FeedState.t,
  config: LensConfig.t,
): TransformResult.t => {
  // Reorder to deprioritize recent/trending
  {
    actions: [],
    narrative: "Prioritizing non-trending and archival content",
  }
}

// Locality Lens: Emphasize geographically nearby content
let applyLocalityLens = (
  feedState: FeedState.t,
  config: LensConfig.t,
): TransformResult.t => {
  {
    actions: [],
    narrative: "Emphasizing local and nearby content",
  }
}

// Serendipity Lens: Maximize surprise and novelty
let applySerendipityLens = (
  feedState: FeedState.t,
  config: LensConfig.t,
): TransformResult.t => {
  {
    actions: [],
    narrative: "Maximizing novelty and serendipitous discovery",
  }
}

// Main lens application dispatcher
let applyLens = (
  lensType: Membrane.State.lensType,
  feedState: FeedState.t,
  config: LensConfig.t,
): option<TransformResult.t> => {
  switch lensType {
  | Membrane.State.None => None
  | Opposition => Some(applyOppositionLens(feedState, config))
  | RandomWalk => Some(applyRandomWalkLens(feedState, config))
  | TimeShift => Some(applyTimeShiftLens(feedState, config))
  | Locality => Some(applyLocalityLens(feedState, config))
  | Serendipity => Some(applySerendipityLens(feedState, config))
  }
}
