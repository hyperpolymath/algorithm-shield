// SPDX-License-Identifier: PMPL-1.0-or-later
// Popup UI controller with security hardening and accessibility features

// ============================================================================
// SECURITY MODULE
// ============================================================================

const Security = {
  /**
   * Sanitize text content to prevent XSS
   * @param {string} text - Untrusted text input
   * @returns {string} Sanitized text
   */
  sanitizeText(text) {
    if (typeof text !== 'string') return ''
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  },

  /**
   * Validate state object structure
   * @param {object} state - State object from storage
   * @returns {boolean} True if valid
   */
  validateState(state) {
    if (!state || typeof state !== 'object') return false

    // Check required fields
    if (typeof state.mode !== 'string') return false
    if (typeof state.membraneThickness !== 'number') return false
    if (typeof state.isPaused !== 'boolean') return false

    // Validate ranges
    if (state.membraneThickness < 0 || state.membraneThickness > 1) return false

    // Validate enums
    const validModes = ['normal', 'persona']
    if (!validModes.includes(state.mode)) return false

    const validLenses = ['opposition', 'random-walk', 'time-shift', 'serendipity', null]
    if (!validLenses.includes(state.activeLens)) return false

    const validPersonas = ['gardener', 'tech-skeptic', 'art-student', null]
    if (!validPersonas.includes(state.activePersona)) return false

    return true
  },

  /**
   * Validate message structure from content script
   * @param {object} message - Message object
   * @returns {boolean} True if valid
   */
  validateMessage(message) {
    if (!message || typeof message !== 'object') return false

    const validTypes = [
      'TRIGGER_BREACH',
      'ACTIVATE_LENS',
      'ACTIVATE_PERSONA',
      'UPDATE_BUBBLE_MAP'
    ]

    return validTypes.includes(message.type)
  },

  /**
   * Sanitize HTML for safe rendering
   * @param {string} html - HTML string
   * @returns {string} Sanitized HTML
   */
  sanitizeHTML(html) {
    if (typeof html !== 'string') return ''

    // Simple whitelist-based sanitizer
    // For production, consider using DOMPurify library
    const allowedTags = ['p', 'span', 'div', 'strong', 'em']
    const div = document.createElement('div')
    div.innerHTML = html

    // Remove all scripts and event handlers
    const scripts = div.querySelectorAll('script')
    scripts.forEach(script => script.remove())

    // Remove all inline event handlers
    div.querySelectorAll('*').forEach(el => {
      Array.from(el.attributes).forEach(attr => {
        if (attr.name.startsWith('on')) {
          el.removeAttribute(attr.name)
        }
      })
    })

    return div.innerHTML
  }
}

// ============================================================================
// ACCESSIBILITY MODULE
// ============================================================================

const Accessibility = {
  /**
   * Initialize keyboard navigation
   */
  initKeyboardNav() {
    // Escape key closes tooltips
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        this.hideTooltip()
      }
    })

    // Arrow keys for lens/persona navigation
    this.setupArrowKeyNav('.lens-grid .lens-card')
    this.setupArrowKeyNav('.persona-grid .persona-card')
  },

  /**
   * Setup arrow key navigation for a grid
   * @param {string} selector - CSS selector for grid items
   */
  setupArrowKeyNav(selector) {
    const cards = document.querySelectorAll(selector)

    cards.forEach((card, index) => {
      card.addEventListener('keydown', (e) => {
        let targetIndex = index

        switch (e.key) {
          case 'ArrowRight':
            targetIndex = (index + 1) % cards.length
            e.preventDefault()
            break
          case 'ArrowLeft':
            targetIndex = (index - 1 + cards.length) % cards.length
            e.preventDefault()
            break
          case 'ArrowDown':
            targetIndex = (index + 2) % cards.length
            e.preventDefault()
            break
          case 'ArrowUp':
            targetIndex = (index - 2 + cards.length) % cards.length
            e.preventDefault()
            break
        }

        if (targetIndex !== index) {
          cards[targetIndex].focus()
        }
      })
    })
  },

  /**
   * Show tooltip
   * @param {HTMLElement} trigger - Element that triggered tooltip
   */
  showTooltip(trigger) {
    const tooltipText = trigger.getAttribute('data-tooltip')
    if (!tooltipText) return

    const tooltip = document.getElementById('tooltip')
    if (!tooltip) return

    // Sanitize tooltip text
    tooltip.textContent = tooltipText
    tooltip.setAttribute('aria-hidden', 'false')

    // Position tooltip near trigger
    const rect = trigger.getBoundingClientRect()
    tooltip.style.top = `${rect.bottom + 8}px`
    tooltip.style.left = `${rect.left}px`
    tooltip.classList.add('visible')

    // Announce to screen readers
    tooltip.setAttribute('aria-live', 'polite')
  },

  /**
   * Hide tooltip
   */
  hideTooltip() {
    const tooltip = document.getElementById('tooltip')
    if (!tooltip) return

    tooltip.classList.remove('visible')
    tooltip.setAttribute('aria-hidden', 'true')
  },

  /**
   * Update ARIA attributes for state changes
   * @param {string} elementId - Element ID
   * @param {object} attrs - ARIA attributes to update
   */
  updateARIA(elementId, attrs) {
    const element = document.getElementById(elementId)
    if (!element) return

    Object.entries(attrs).forEach(([key, value]) => {
      if (key.startsWith('aria-')) {
        element.setAttribute(key, value)
      }
    })
  },

  /**
   * Announce message to screen readers
   * @param {string} message - Message to announce
   * @param {string} priority - 'polite' or 'assertive'
   */
  announce(message, priority = 'polite') {
    const announcer = document.createElement('div')
    announcer.setAttribute('role', 'status')
    announcer.setAttribute('aria-live', priority)
    announcer.className = 'visually-hidden'
    announcer.textContent = Security.sanitizeText(message)

    document.body.appendChild(announcer)

    // Remove after announcement
    setTimeout(() => announcer.remove(), 1000)
  }
}

// ============================================================================
// STATE MANAGEMENT
// ============================================================================

let state = {
  mode: 'normal',
  activeLens: null,
  activePersona: null,
  membraneThickness: 0.5,
  isPaused: false
}

function updateUI() {
  // Update mode indicator
  const modeEl = document.getElementById('mode-indicator')
  if (modeEl) {
    const modeText = state.activePersona
      ? `Persona: ${state.activePersona}`
      : state.mode.charAt(0).toUpperCase() + state.mode.slice(1)

    modeEl.textContent = Security.sanitizeText(modeText)
  }

  // Update thickness bar
  const thicknessFill = document.getElementById('thickness-fill')
  const thicknessValue = document.getElementById('thickness-value')
  if (thicknessFill && thicknessValue) {
    const percentage = Math.round(state.membraneThickness * 100)
    thicknessFill.style.width = `${percentage}%`
    thicknessValue.textContent = state.membraneThickness.toFixed(2)

    // Update ARIA attributes
    const thicknessBar = thicknessFill.parentElement
    if (thicknessBar) {
      thicknessBar.setAttribute('aria-valuenow', state.membraneThickness)
      thicknessBar.setAttribute('aria-valuetext', `${percentage} percent`)
    }
  }

  // Update lens active states and ARIA
  document.querySelectorAll('.lens-card').forEach(card => {
    const lens = card.dataset.lens
    const isActive = lens === state.activeLens

    card.classList.toggle('active', isActive)
    card.setAttribute('aria-pressed', isActive ? 'true' : 'false')
  })

  // Update persona active states and ARIA
  document.querySelectorAll('.persona-card').forEach(card => {
    const persona = card.dataset.persona
    const isActive = persona === state.activePersona

    card.classList.toggle('active', isActive)
    card.setAttribute('aria-pressed', isActive ? 'true' : 'false')
  })

  // Sync to storage (with validation)
  if (Security.validateState(state)) {
    chrome.storage.local.set({ shieldState: state })
  }
}

// ============================================================================
// EVENT HANDLERS
// ============================================================================

document.addEventListener('DOMContentLoaded', () => {
  // Initialize accessibility features
  Accessibility.initKeyboardNav()

  // Setup tooltip triggers
  document.querySelectorAll('[data-tooltip]').forEach(trigger => {
    trigger.addEventListener('mouseenter', () => Accessibility.showTooltip(trigger))
    trigger.addEventListener('mouseleave', () => Accessibility.hideTooltip())
    trigger.addEventListener('focus', () => Accessibility.showTooltip(trigger))
    trigger.addEventListener('blur', () => Accessibility.hideTooltip())
  })

  // Load saved state (with validation)
  chrome.storage.local.get('shieldState', (result) => {
    if (result.shieldState && Security.validateState(result.shieldState)) {
      state = { ...state, ...result.shieldState }
      updateUI()
    }
  })

  // Breach button
  const breachBtn = document.getElementById('breach-btn')
  breachBtn?.addEventListener('click', () => {
    chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
      if (tabs[0]) {
        chrome.tabs.sendMessage(tabs[0].id, {
          type: 'TRIGGER_BREACH'
        }).then(() => {
          Accessibility.announce('Membrane breach initiated', 'polite')
        }).catch(err => {
          console.log('Content script not loaded on this page:', err.message)
          Accessibility.announce('Shield only works on supported platforms like YouTube and Twitter', 'assertive')
        })
      }
    })
  })

  // Pause button
  const pauseBtn = document.getElementById('pause-btn')
  pauseBtn?.addEventListener('click', () => {
    state.isPaused = !state.isPaused

    const buttonText = state.isPaused ? 'Resume Shield' : 'Pause Shield'
    const buttonIcon = state.isPaused ? '▶️' : '⏸️'

    pauseBtn.innerHTML = `<span aria-hidden="true">${buttonIcon}</span> <span>${buttonText}</span>`
    pauseBtn.setAttribute('aria-label', state.isPaused ? 'Resume shield protection' : 'Pause shield protection')

    Accessibility.announce(
      state.isPaused ? 'Shield paused' : 'Shield resumed',
      'polite'
    )

    updateUI()
  })

  // Lens cards
  document.querySelectorAll('.lens-card').forEach(card => {
    card.addEventListener('click', () => {
      const lens = card.dataset.lens
      const wasActive = state.activeLens === lens

      if (wasActive) {
        state.activeLens = null
        state.membraneThickness = 0.5
        Accessibility.announce(`${lens} lens deactivated`, 'polite')
      } else {
        state.activeLens = lens
        state.membraneThickness = 0.7
        Accessibility.announce(`${lens} lens activated`, 'polite')
      }

      updateUI()

      // Notify content script
      chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
        if (tabs[0]) {
          chrome.tabs.sendMessage(tabs[0].id, {
            type: 'ACTIVATE_LENS',
            lens: state.activeLens
          }).catch(() => {
            // Silently fail if content script not available
          })
        }
      })
    })
  })

  // Persona cards
  document.querySelectorAll('.persona-card').forEach(card => {
    card.addEventListener('click', () => {
      const persona = card.dataset.persona
      const wasActive = state.activePersona === persona

      if (wasActive) {
        state.activePersona = null
        state.mode = 'normal'
        state.membraneThickness = 0.5
        Accessibility.announce(`${persona} persona deactivated`, 'polite')
      } else {
        state.activePersona = persona
        state.mode = 'persona'
        state.membraneThickness = 0.6
        Accessibility.announce(`${persona} persona activated`, 'polite')
      }

      updateUI()

      // Notify content script
      chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
        if (tabs[0]) {
          chrome.tabs.sendMessage(tabs[0].id, {
            type: 'ACTIVATE_PERSONA',
            persona: state.activePersona
          }).catch(() => {
            // Silently fail if content script not available
          })
        }
      })
    })
  })
})

// Listen for updates from content script (with validation)
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (!Security.validateMessage(message)) {
    console.warn('Invalid message received:', message)
    return
  }

  if (message.type === 'UPDATE_BUBBLE_MAP' && message.data) {
    const bubbleMap = document.getElementById('bubble-map')
    if (bubbleMap && message.data.html) {
      bubbleMap.innerHTML = Security.sanitizeHTML(message.data.html)
      Accessibility.announce('Bubble map updated', 'polite')
    }
  }

  sendResponse({ received: true })
})
