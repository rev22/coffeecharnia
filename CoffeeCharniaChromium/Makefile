TARGETS=coffee-script.js coffeecharnia.js embeddedScripts.js

all: $(TARGETS)

clean:
	rm -f $(TARGETS)

%.js: %.coffee
	refcoffee -bc $<

coffee-script.js: ../../reflective-coffeescript/extras/coffee-script.js
	cp -av $< $@

coffeecharnia.coffee: ../coffeecharnia.coffee
	( cat $<; echo; echo 'window.coffeecharnia.spawn()' ) >$@

embeddedScripts.js: ../lib/embeddedScripts.js
	cp -uav $< $@
