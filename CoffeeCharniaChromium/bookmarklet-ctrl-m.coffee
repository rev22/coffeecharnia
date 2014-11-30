do->
  version = "0.2.18"
  document.coffeecharniaBookmarkletVersion = version
  v = "?version=#{version}"
  injectSrc = chrome.extension.getURL("coffeecharnia.js") + v
  coffeescriptUrl = chrome.extension.getURL("coffee-script.js") + v

  loadUp = (x = injectSrc)->
      s = document.createElement("script")
      s.src = x
      document.body.appendChild s

  h = (e)->
    # Remap Ctrl-M
    if (e.keyCode == 77 && (navigator.platform.match("Mac") then e.metaKey else e.ctrlKey))
      e.preventDefault()
      e.stopPropagation()
      loadUp(coffeescriptUrl)
      loadUp()

  document.addEventListener("keydown", h, false)

