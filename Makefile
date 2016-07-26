WEBPACK=node_modules/.bin/webpack --config webpack.config.js
SRC=src
SASS=node_modules/.bin/node-sass
UGLIFY=node_modules/.bin/uglifyjs
CONCURRENT=node_modules/.bin/concurrent
MODULE=__MODULE_NAME__
INTERMEDIATES_DIR=.intermediates
TARGET_DIR=www
TEMPLATES_JS=www/templates.js
SOURCE_JS=src/app.js $(shell find src/{components,views} -name '*.js' -or -name '*.es6')
VENDOR_JS=  \
		bower_components/angular/angular.min.js

TARGETS=www/style.css www/vendor.js www/app.js $(TEMPLATES_JS)

build: node_modules bower_components node_modules $(TARGETS)

submodules: .PHONY
	bash -c 'if [[ -z $$(cd src/lib/api-js && git status -s && cd ../ng-jsdata && git status -s ) ]]; then echo "Updating submodules..." && git submodule update --init;	fi'

bower_components: bower.json
	bower install

node_modules: package.json
	npm install
	touch node_modules

update: node_modules

clean:
	rm -rf $(TARGETS)

# Compile all of the templates in our project into template-cache-injected strings, so there is no retrieval of templates,
# they're automatically loaded on startup.
$(TEMPLATES_JS): $(shell find $(SRC)/{components,views} -name '*.html')
	mkdir -p $(INTERMEDIATES_DIR)
	@echo "Compiling templatecache..."
	@echo 'angular.module("$(MODULE)").run(["$$templateCache",function($$templateCache) {' > $@
	@echo 'console.log("loading templates...");' >> $@
# somewhat complex encoding of the file for embedding in JS, replaces newlines with spaces, double-quotes with '\"', and
# ensures that single-quotes are transported (through echo's shell-expansion) correctly into the final document
# see http://stackoverflow.com/questions/1250079/how-to-escape-single-quotes-within-single-quoted-strings for an explanation
# of the former
	@$(foreach file,$^,echo '$$templateCache.put("$(file:src/%=%)","$(shell cat $(file) | tr '\n' ' ' | sed 's/"/\\"/g' | sed 's/'\''/'\''\\'\'''\''/g' )");' >> $@;)
	@echo 'console.log("Done...");' >> $@
	@echo '}]);' >> $@
	@echo "Done."

$(TARGET_DIR)/fonts: bower_components/ionic/fonts
	cp -r $< $@

www/style.css: src/style.scss $(shell find src -name '*.scss' -or -name '*.css' -or -name '*.sass')
	$(SASS) $< $@

www/vendor.js: $(VENDOR_JS)
	$(UGLIFY) --source-map $@.map --source-map-include-sources --source-map-url vendor.js.map $^ -o $@

www/app.js: $(SOURCE_JS)
	@echo Compiling $(SOURCE_JS)
	$(WEBPACK) --devtool sourcemap $@

serve: build
	rm www/app.js
	$(CONCURRENT) --kill-others "npm run watch-sass" "npm run serve"

help:
	@echo 'make serve : builds and serves the app in a web browser'
	@echo 'make clean : remove all built products'
	@echo 'make serve : serve up a version of the application, and update as changes occur'

.PHONY:
