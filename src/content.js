// Content Script for Algorithm Shield
// ====================================
//
// PURPOSE:
//   Runs on YouTube/Twitter/TikTok pages to:
//   1. Extract feed content (video titles, channels)
//   2. Classify content into categories
//   3. Calculate bubble metrics (diversity, bubble score)
//   4. Send metrics to background for rule evaluation
//   5. Execute actions (open tabs, show notifications)
//
// WHAT THIS SCRIPT CAN SEE:
//   - Video titles visible on the current page
//   - Channel names
//   - DOM structure (to find video elements)
//
// WHAT THIS SCRIPT CANNOT SEE:
//   - Your watch history
//   - What you click on
//   - Content on other tabs
//   - Your account information
//
// PRIVACY:
//   - Only analyzes content currently visible on screen
//   - Doesn't track individual videos (only aggregated categories)
//   - Sends only percentages to background (not titles/URLs)
//
// TRANSPARENCY:
//   - All actions logged to console (open DevTools to inspect)
//   - Metrics calculation is open-source (see metrics-calculator.js)

// Note: metrics-calculator.js is loaded before this script via manifest
// Functions available: analyzeFeed(), classifyContent(), calculateDiversity(), calculateBubbleScore()

console.log('🛡️ Algorithm Shield active');

// Detect platform
const platformInfo = detectPlatform();
console.log('🌐 Platform detected:', platformInfo);

// Verify metrics-calculator.js loaded correctly
console.log('🔍 Checking metrics functions availability:');
console.log('  - analyzeFeed:', typeof analyzeFeed);
console.log('  - classifyContent:', typeof classifyContent);
console.log('  - calculateDiversity:', typeof calculateDiversity);
console.log('  - calculateBubbleScore:', typeof calculateBubbleScore);

let shieldState = {
  enabled: true,
  activeLens: null,
  activePersona: null,
  lastAnalysisTime: 0,
  platformInfo: platformInfo
};

/**
 * Detect which platform we're on and what mode
 *
 * RETURNS: {platform, mode, supported}
 *
 * EXAMPLES:
 *   {platform: 'google', mode: 'shopping', supported: true}
 *   {platform: 'amazon', mode: 'search', supported: true}
 *   {platform: 'youtube', mode: 'feed', supported: true}
 */
function detectPlatform() {
  const hostname = window.location.hostname;
  const pathname = window.location.pathname;
  const searchParams = new URLSearchParams(window.location.search);

  // Google (all modes)
  if (hostname.includes('google.com')) {
    const tbm = searchParams.get('tbm'); // search mode parameter
    if (tbm === 'shop') return {platform: 'google', mode: 'shopping', supported: true};
    if (tbm === 'vid') return {platform: 'google', mode: 'video', supported: true};
    if (tbm === 'nws') return {platform: 'google', mode: 'news', supported: true};
    if (tbm === 'isch') return {platform: 'google', mode: 'images', supported: true};
    if (pathname.includes('/maps')) return {platform: 'google', mode: 'maps', supported: true};
    if (searchParams.has('q')) return {platform: 'google', mode: 'web', supported: true};
    return {platform: 'google', mode: 'homepage', supported: false};
  }

  // Bing (all modes)
  if (hostname.includes('bing.com')) {
    if (pathname.includes('/shop')) return {platform: 'bing', mode: 'shopping', supported: true};
    if (pathname.includes('/videos')) return {platform: 'bing', mode: 'video', supported: true};
    if (pathname.includes('/news')) return {platform: 'bing', mode: 'news', supported: true};
    if (pathname.includes('/images')) return {platform: 'bing', mode: 'images', supported: true};
    if (searchParams.has('q')) return {platform: 'bing', mode: 'web', supported: true};
    return {platform: 'bing', mode: 'homepage', supported: false};
  }

  // DuckDuckGo
  if (hostname.includes('duckduckgo.com')) {
    const iax = searchParams.get('iax'); // search type
    const ia = searchParams.get('ia');
    if (iax === 'shopping' || ia === 'shopping') return {platform: 'duckduckgo', mode: 'shopping', supported: true};
    if (iax === 'videos' || ia === 'videos') return {platform: 'duckduckgo', mode: 'video', supported: true};
    if (iax === 'news' || ia === 'news') return {platform: 'duckduckgo', mode: 'news', supported: true};
    if (iax === 'images' || ia === 'images') return {platform: 'duckduckgo', mode: 'images', supported: true};
    if (searchParams.has('q')) return {platform: 'duckduckgo', mode: 'web', supported: true};
    return {platform: 'duckduckgo', mode: 'homepage', supported: false};
  }

  // Amazon
  if (hostname.includes('amazon.com') || hostname.includes('amazon.co.uk')) {
    if (pathname.includes('/s/') || searchParams.has('k')) return {platform: 'amazon', mode: 'search', supported: true};
    if (pathname.includes('/dp/') || pathname.includes('/gp/product')) return {platform: 'amazon', mode: 'product', supported: false};
    return {platform: 'amazon', mode: 'browse', supported: true};
  }

  // eBay
  if (hostname.includes('ebay.com')) {
    if (pathname.includes('/sch/') || searchParams.has('_nkw')) return {platform: 'ebay', mode: 'search', supported: true};
    return {platform: 'ebay', mode: 'browse', supported: true};
  }

  // Walmart
  if (hostname.includes('walmart.com')) {
    if (pathname.includes('/search')) return {platform: 'walmart', mode: 'search', supported: true};
    return {platform: 'walmart', mode: 'browse', supported: true};
  }

  // Etsy
  if (hostname.includes('etsy.com')) {
    if (pathname.includes('/search')) return {platform: 'etsy', mode: 'search', supported: true};
    return {platform: 'etsy', mode: 'browse', supported: true};
  }

  // YouTube
  if (hostname.includes('youtube.com')) {
    if (pathname === '/' || pathname === '/feed/subscriptions') return {platform: 'youtube', mode: 'feed', supported: true};
    if (pathname.includes('/results')) return {platform: 'youtube', mode: 'search', supported: true};
    return {platform: 'youtube', mode: 'watch', supported: false};
  }

  // Twitter/X
  if (hostname.includes('twitter.com') || hostname.includes('x.com')) {
    return {platform: 'twitter', mode: 'feed', supported: true};
  }

  // TikTok
  if (hostname.includes('tiktok.com')) {
    return {platform: 'tiktok', mode: 'feed', supported: true};
  }

  // Unsupported site
  return {platform: 'unknown', mode: 'unknown', supported: false};
}

/**
 * Extract search results from Google
 */
function extractGoogleResults() {
  const results = [];
  const mode = shieldState.platformInfo.mode;

  if (mode === 'web') {
    // Web search results
    const resultDivs = document.querySelectorAll('div.g, div[data-sokoban-container]');
    for (const div of resultDivs) {
      const titleElement = div.querySelector('h3');
      const title = titleElement?.textContent?.trim() || '';
      const snippetElement = div.querySelector('div[data-sncf], div.VwiC3b');
      const snippet = snippetElement?.textContent?.trim() || '';
      if (title) {
        results.push({title, description: snippet, source: 'google-web'});
      }
    }
  } else if (mode === 'shopping') {
    // Shopping results
    const productDivs = document.querySelectorAll('div[data-docid]');
    for (const div of productDivs) {
      const titleElement = div.querySelector('h3, h4');
      const title = titleElement?.textContent?.trim() || '';
      if (title) {
        results.push({title, description: '', source: 'google-shopping'});
      }
    }
  } else if (mode === 'news') {
    // News results
    const newsCards = document.querySelectorAll('div[role="heading"]');
    for (const card of newsCards) {
      const title = card.textContent?.trim() || '';
      if (title) {
        results.push({title, description: '', source: 'google-news'});
      }
    }
  }

  console.log(`🔍 Extracted ${results.length} results from Google ${mode}`);
  return results;
}

/**
 * Extract search results from Bing
 */
function extractBingResults() {
  const results = [];
  const mode = shieldState.platformInfo.mode;

  if (mode === 'web') {
    const resultItems = document.querySelectorAll('li.b_algo');
    for (const item of resultItems) {
      const titleElement = item.querySelector('h2 a');
      const title = titleElement?.textContent?.trim() || '';
      if (title) {
        results.push({title, description: '', source: 'bing-web'});
      }
    }
  } else if (mode === 'shopping') {
    const productCards = document.querySelectorAll('div.sp_carditem');
    for (const card of productCards) {
      const titleElement = card.querySelector('a.title');
      const title = titleElement?.textContent?.trim() || '';
      if (title) {
        results.push({title, description: '', source: 'bing-shopping'});
      }
    }
  }

  console.log(`🔍 Extracted ${results.length} results from Bing ${mode}`);
  return results;
}

/**
 * Extract search results from DuckDuckGo
 */
function extractDuckDuckGoResults() {
  const results = [];
  const resultArticles = document.querySelectorAll('article[data-testid="result"]');

  for (const article of resultArticles) {
    const titleElement = article.querySelector('h2');
    const title = titleElement?.textContent?.trim() || '';
    if (title) {
      results.push({title, description: '', source: 'duckduckgo'});
    }
  }

  console.log(`🔍 Extracted ${results.length} results from DuckDuckGo`);
  return results;
}

/**
 * Extract product results from Amazon
 */
function extractAmazonResults() {
  const results = [];
  const productDivs = document.querySelectorAll('div[data-component-type="s-search-result"]');

  for (const div of productDivs) {
    const titleElement = div.querySelector('h2 a span');
    const title = titleElement?.textContent?.trim() || '';
    if (title) {
      results.push({title, description: '', source: 'amazon'});
    }
  }

  console.log(`🛒 Extracted ${results.length} products from Amazon`);
  return results;
}

/**
 * Extract product results from eBay
 */
function extractEbayResults() {
  const results = [];
  const listingDivs = document.querySelectorAll('div.s-item__info');

  for (const div of listingDivs) {
    const titleElement = div.querySelector('div.s-item__title span');
    const title = titleElement?.textContent?.trim() || '';
    if (title && title !== 'Shop on eBay') {
      results.push({title, description: '', source: 'ebay'});
    }
  }

  console.log(`🛒 Extracted ${results.length} listings from eBay`);
  return results;
}

/**
 * Extract feed items from YouTube DOM
 *
 * WHAT THIS DOES:
 *   - Queries DOM for video elements (ytd-rich-item-renderer or ytd-video-renderer)
 *   - Extracts title and channel name from each
 *   - Returns array of {title, channel, url}
 *
 * PRIVACY:
 *   - Only reads currently visible items on page
 *   - Doesn't store URLs (only uses for analysis)
 *   - Runs entirely locally (no network calls)
 */
function extractYouTubeResults() {
  const feedItems = [];

  // YouTube feed uses different selectors depending on page:
  // Homepage: ytd-rich-item-renderer
  // Search/Channel: ytd-video-renderer
  const videoSelectors = [
    'ytd-rich-item-renderer',
    'ytd-video-renderer',
    'ytd-grid-video-renderer'
  ];

  for (const selector of videoSelectors) {
    const videoElements = document.querySelectorAll(selector);

    for (const element of videoElements) {
      try {
        // Extract title
        const titleElement = element.querySelector('#video-title, h3 a');
        const title = titleElement?.textContent?.trim() || '';

        // Extract channel name
        const channelElement = element.querySelector('#channel-name a, ytd-channel-name a');
        const channel = channelElement?.textContent?.trim() || '';

        // Extract URL (for logging, not stored)
        const url = titleElement?.href || '';

        if (title) {
          feedItems.push({ title, channel, url, source: 'youtube' });
        }
      } catch (error) {
        // Skip malformed elements
        console.debug('Could not extract video data:', error);
      }
    }
  }

  console.log(`📹 Extracted ${feedItems.length} videos from YouTube`);
  return feedItems;
}

/**
 * Universal extractor - routes to platform-specific function
 */
function extractResults() {
  const {platform, mode} = shieldState.platformInfo;

  console.log(`🔧 Extracting results for ${platform} (${mode})...`);

  if (platform === 'google') return extractGoogleResults();
  if (platform === 'bing') return extractBingResults();
  if (platform === 'duckduckgo') return extractDuckDuckGoResults();
  if (platform === 'amazon') return extractAmazonResults();
  if (platform === 'ebay') return extractEbayResults();
  if (platform === 'youtube') return extractYouTubeResults();

  console.warn(`⚠️ No extractor for platform: ${platform}`);
  return [];
}

/**
 * Analyze current results/feed and send metrics to background
 *
 * TRANSPARENCY:
 *   - Logs category distribution to console
 *   - Sends only aggregated metrics (not individual items)
 *
 * WORKS ON:
 *   - Search engines (Google, Bing, DuckDuckGo)
 *   - Shopping sites (Amazon, eBay, Walmart, Etsy)
 *   - Social media (YouTube, Twitter, TikTok)
 */
function analyzeCurrentFeed() {
  console.log('🔬 analyzeCurrentFeed() called');

  // Don't spam analysis - max once per 10 seconds
  const now = Date.now();
  const timeSinceLastAnalysis = now - shieldState.lastAnalysisTime;
  console.log(`⏱️ Time since last analysis: ${timeSinceLastAnalysis}ms (threshold: 10000ms)`);

  if (timeSinceLastAnalysis < 10000 && shieldState.lastAnalysisTime !== 0) {
    console.log('⏸️ Throttled - too soon since last analysis');
    return;
  }
  shieldState.lastAnalysisTime = now;

  const {platform, mode} = shieldState.platformInfo;
  console.log(`🔬 Analyzing ${platform} (${mode})...`);

  // Extract results/feed items from page (universal extractor)
  const items = extractResults();
  console.log(`📦 extractResults() returned ${items.length} items`);

  if (items.length === 0) {
    console.warn(`⚠️ No results found on ${platform} - waiting for page to load`);
    return;
  }

  console.log('📊 Calling analyzeFeed()...');

  // Calculate metrics
  const metrics = analyzeFeed(items);
  console.log('✅ analyzeFeed() completed:', metrics);

  // Send to background for rule evaluation
  // PRIVACY: We send only percentages, not titles or URLs
  console.log('📤 Sending metrics to background...');
  chrome.runtime.sendMessage({
    type: 'UPDATE_METRICS',
    platform: platform,
    mode: mode,
    feedDiversity: metrics.diversity,
    bubbleScore: metrics.bubbleScore,
    categoryDistribution: metrics.categoryPercentages, // Percentages only!
    totalItems: metrics.totalItems
  });

  console.log(`✅ Metrics sent - diversity: ${(metrics.diversity * 100).toFixed(1)}%, bubble: ${(metrics.bubbleScore * 100).toFixed(1)}%`);
}

// Listen for messages from popup and background
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  console.log('📨 Message received:', message.type);

  switch (message.type) {
    case 'TRIGGER_BREACH':
      console.log('🌐 Membrane breach requested by user');
      // Will trigger lens-based URL generation
      // TODO: Wire to Actuator module
      sendResponse({ status: 'breach_initiated' });
      break;

    case 'ACTIVATE_LENS':
      shieldState.activeLens = message.lens;
      console.log('🔍 Lens activated:', message.lens);
      // TODO: Wire to Lens module
      sendResponse({ status: 'lens_activated' });
      break;

    case 'ACTIVATE_PERSONA':
      shieldState.activePersona = message.persona;
      console.log('👤 Persona activated:', message.persona);
      // TODO: Wire to Persona module
      sendResponse({ status: 'persona_activated' });
      break;

    case 'EXECUTE_ACTIONS':
      // Background sent actions from rule engine
      console.log('🎯 Executing actions from rule engine:', message.actions);
      executeActions(message.actions);
      sendResponse({ status: 'actions_executed' });
      break;

    case 'ANALYZE_FEED':
      // Popup requested immediate analysis
      analyzeCurrentFeed();
      sendResponse({ status: 'analysis_complete' });
      break;

    default:
      sendResponse({ status: 'unknown_message' });
  }

  return true; // Keep channel open for async response
});

/**
 * Execute actions suggested by rule engine
 *
 * TRANSPARENCY:
 *   - Logs each action before executing
 *   - You can see what the engine decided
 */
function executeActions(actions) {
  for (const action of actions) {
    console.log('⚡ Executing action:', action);

    switch (action.type) {
      case 'suggest_breach':
        // Show subtle notification suggesting membrane breach
        console.log(`💡 Suggestion: Cross membrane using ${action.lens} lens`);
        // TODO: Show in-page notification
        break;

      case 'activate_lens':
        console.log(`🔍 Auto-activating ${action.lens} lens - ${action.reason}`);
        shieldState.activeLens = action.lens;
        // TODO: Update UI state
        break;

      case 'show_notification':
        console.log(`📢 ${action.message}`);
        // TODO: Show browser notification (with permission)
        break;

      default:
        console.warn('Unknown action type:', action.type);
    }
  }
}

/**
 * Observer: Watch for results/feed updates
 *
 * WHAT THIS DOES:
 *   - Uses MutationObserver to detect when page loads new content
 *   - Re-analyzes when search results or feed changes
 *   - Throttled to avoid performance impact
 *
 * WORKS ON:
 *   - Search engines (Google, Bing, DuckDuckGo)
 *   - Shopping sites (Amazon, eBay, etc.)
 *   - Social media (YouTube, Twitter, TikTok)
 */
function observeContent() {
  const {platform, mode} = shieldState.platformInfo;
  console.log(`👁️ Observing ${platform} (${mode}) for changes...`);
  console.log('⏲️ Setting 2-second timer for initial analysis...');

  // Analyze immediately on load
  setTimeout(() => {
    console.log('⏰ Timer fired! Calling analyzeCurrentFeed()...');
    analyzeCurrentFeed();
  }, 2000); // Wait 2s for page to settle

  // Watch for DOM changes
  const observer = new MutationObserver((mutations) => {
    // Check if new content was added
    const hasNewContent = mutations.some(m => m.addedNodes.length > 0);

    if (hasNewContent) {
      console.log('🔄 Content updated, re-analyzing...');
      analyzeCurrentFeed();
    }
  });

  // Observe the main content container (varies by platform)
  let contentContainer = null;

  if (platform === 'google') {
    contentContainer = document.querySelector('#search, #rso, div[role="main"]');
  } else if (platform === 'bing') {
    contentContainer = document.querySelector('#b_results, main');
  } else if (platform === 'duckduckgo') {
    contentContainer = document.querySelector('ol[data-testid="mainline"]');
  } else if (platform === 'amazon') {
    contentContainer = document.querySelector('div.s-main-slot, div[data-component-type="s-search-results"]');
  } else if (platform === 'ebay') {
    contentContainer = document.querySelector('div.srp-results');
  } else if (platform === 'youtube') {
    contentContainer = document.querySelector('ytd-rich-grid-renderer, ytd-section-list-renderer, ytd-two-column-search-results-renderer');
  }

  if (contentContainer) {
    observer.observe(contentContainer, {
      childList: true,
      subtree: true
    });
    console.log('✅ Content observer active');
  } else {
    console.warn(`⏳ ${platform} content container not ready - will retry in 3s`);
    setTimeout(observeContent, 3000); // Retry after 3s
  }
}

/**
 * Initialize based on detected platform
 */
function initializePlatform() {
  const {platform, mode, supported} = shieldState.platformInfo;

  if (!supported) {
    if (platform === 'unknown') {
      console.log('ℹ️ Algorithm Shield loaded but inactive on this site');
      console.log('💡 Supported platforms: Google, Bing, DuckDuckGo, Amazon, eBay, YouTube, Twitter, TikTok');
    } else {
      console.log(`ℹ️ Algorithm Shield active on ${platform} but not analyzing this page (${mode})`);
    }
    return;
  }

  console.log(`✅ Initializing ${platform} (${mode}) analysis...`);
  observeContent();
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializePlatform);
} else {
  initializePlatform();
}
