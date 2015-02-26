var b, jsLoad;
 
jsLoad = function(src, cb) {
  var x, y;
  x = document.createElement('script');
  x.type = 'text/javascript';
  x.src = src;
  y = 1;
  x.onload = x.onreadystatechange = function() {
    if (y && !this.readyState || this.readyState === 'complete') {
      y = 0;
      x.parentNode.removeChild(x);
      return typeof cb === "function" ? cb() : void 0;
    }
  };
  return document.head.appendChild(x);
};
 
b = "https://github.com/rev22/coffeecharnia/raw/gh-pages"; b = "http://rev22.github.com/coffeecharnia"; jsLoad("" + b + "/lib/embeddedScripts.js", function() {
  return jsLoad("" + b + "/coffeecharnia.js", function() {
    try {
      // window.coffeecharnia.coffeescriptUrl = "" + b + "/coffee-script.js";
      return coffeecharnia.spawn();
    } catch (error) {
      alert("Loading error: " + error)
    }
  });
});
