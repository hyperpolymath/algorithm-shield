// ReScript bindings for chrome.runtime API

type message

// Message passing
module Runtime = {
  @val @scope(("chrome", "runtime"))
  external sendMessage: message => promise<message> = "sendMessage"

  // Listen for messages
  type messageListener<'sender, 'sendResponse> = (message, 'sender, 'sendResponse) => bool

  @val @scope(("chrome", "runtime", "onMessage"))
  external addListener: messageListener<'a, 'b> => unit = "addListener"

  // Get extension URL
  @val @scope(("chrome", "runtime"))
  external getURL: string => string = "getURL"
}
