do->
  version = "0.3.45-4"
  document.coffeecharniaBookmarkletVersion = version
  v = "?version=#{version}"
  injectSrc = chrome.extension.getURL("coffeecharnia.js") + v
  libUrl = chrome.extension.getURL("embeddedScripts.js") + v

  loadUp = (x = injectSrc)->
      s = document.createElement("script")
      s.src = x
      s.onload = -> document.body.removeChild s
      document.body.appendChild s

  h = (e)->
    # Remap Ctrl-M
    if (e.keyCode == 77 && (navigator.platform.match("Mac") then e.metaKey else e.ctrlKey))
      e.preventDefault()
      e.stopPropagation()
      loadUp(libUrl)
      loadUp null

  document.addEventListener("keydown", h, false)

