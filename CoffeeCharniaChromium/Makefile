TARGETS=coffee-script.js index.html

all: $(TARGETS)

clean:
	rm -f $(TARGETS)

%.js: %.coffee
	refcoffee -bc $<

coffee-script.js: ../../reflective-coffeescript/extras/coffee-script.js
	cp -av $< $@
