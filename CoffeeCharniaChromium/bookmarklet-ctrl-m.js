// Generated by CoffeeScript 1.8.0-reflective.24
(function() {
  var coffeescriptUrl, h, injectSrc, loadUp, v, version;
  version = "0.3.45-4";
  document.coffeecharniaBookmarkletVersion = version;
  v = "?version=" + version;
  injectSrc = chrome.extension.getURL("coffeecharnia.js") + v;
  coffeescriptUrl = chrome.extension.getURL("coffee-script.js") + v;
  loadUp = function(x) {
    var s;
    if (x == null) {
      x = injectSrc;
    }
    s = document.createElement("script");
    s.src = x;
    s.onload = function() {
      return document.body.removeChild(s);
    };
    return document.body.appendChild(s);
  };
  h = function(e) {
    if (e.keyCode === 77 && (navigator.platform.match("Mac") ? e.metaKey : e.ctrlKey)) {
      e.preventDefault();
      e.stopPropagation();
      loadUp(coffeescriptUrl);
      return loadUp(null);
    }
  };
  return document.addEventListener("keydown", h, false);
})();
