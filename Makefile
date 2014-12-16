TARGETS=coffee-script.js index.html

all: $(TARGETS)

clean:
	rm -f $(TARGETS)

%.html: %.html.coffee
	(sh -c "coffee $< >$@.new" && mv $@.new $@ && touch -r $< $@) || rm -f $@

%.regen.html.coffee: %.html bin/html2cup
	(sh -c "bin/html2cup $< >$@.new" && mv $@.new $@) || rm -f $@

%.html: %.htmlcup bin/html2cup
	(sh -c "bin/html2cup $< >$@.new" && mv $@.new $@) || rm -f $@

%.js: %.coffee
	coffee -bc $<


%.php: %.in.phpcup
	script/cup2php $< $@

%.phpcup: %.in.php
	script/php2cup_body $< $@

%.out.php: %.phpcup
	script/cup2php $< $@

%.out.phpcup: %.php
	script/php2cup_body $< $@


%.js: %.browserify.js
	# browserify -r fs:browserify-fs $< -o $@ || rm $@
	browserify $< -t refcoffeeify --ignore-missing -o $@ || rm $@

coffee-script.js: ../reflective-coffeescript/extras/coffee-script.js
	cp -av $< $@

rebuildCoffeecharnia: coffeecharnia.js
	touch index.html.coffee
	echo >rebuildCoffeecharnia

all: rebuildCoffeecharnia index.html
