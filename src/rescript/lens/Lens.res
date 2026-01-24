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
    !dominantCats->Array.includes(cat)
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
  // Pick 3-5 random items from outside dominant clusters
  {
    actions: [],
    narrative: "Exploring low-probability recommendation paths",
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
