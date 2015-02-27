TARGETS=coffeecharnia.js bookmarklet-ctrl-m.js

all: $(TARGETS)

clean:
	rm -f $(TARGETS)

%.js: %.coffee
	refcoffee -bc $<

# coffee-script.js: ../../reflective-coffeescript/extras/coffee-script.js
# 	cp -av $< $@

coffeecharnia.js: ../coffeecharnia.js ../lib/embeddedScripts.js
	( cat ../lib/embeddedScripts.js; echo; cat ../coffeecharnia.js; echo; echo 'window.coffeecharnia.spawn()' ) >$@

