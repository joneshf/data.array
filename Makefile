bin        = $(shell npm bin)
lsc        = $(bin)/lsc
browserify = $(bin)/browserify
groc       = $(bin)/groc
uglify     = $(bin)/uglifyjs
VERSION    = $(shell node -e 'console.log(require("./package.json").version)')


lib: src/*.ls
	$(lsc) -o lib -c src/*.ls

dist:
	mkdir -p dist

dist/data.array.umd.js: compile dist
	$(browserify) lib/index.js --standalone data-array > $@

dist/data.array.umd.min.js: dist/data.array.umd.js
	$(uglify) --mangle - < $^ > $@

# ----------------------------------------------------------------------
bundle: dist/data.array.umd.js

minify: dist/data.array.umd.min.js

compile: lib

documentation:
	$(groc) --index "README.md"                                              \
	        --out "docs/literate"                                            \
	        src/*.ls test/*.ls test/specs/**.ls README.md

clean:
	rm -rf dist build lib

test:
	$(lsc) test/tap.ls

package: compile documentation bundle minify
	mkdir -p dist/data.array-$(VERSION)
	cp -r docs/literate dist/data.array-$(VERSION)/docs
	cp -r lib dist/data.array-$(VERSION)
	cp dist/*.js dist/data.array-$(VERSION)
	cp package.json dist/data.array-$(VERSION)
	cp README.md dist/data.array-$(VERSION)
	cp LICENCE dist/data.array-$(VERSION)
	cd dist && tar -czf data.array-$(VERSION).tar.gz data.array-$(VERSION)

publish: clean
	npm install
	npm publish

bump:
	node tools/bump-version.js $$VERSION_BUMP

bump-feature:
	VERSION_BUMP=FEATURE $(MAKE) bump

bump-major:
	VERSION_BUMP=MAJOR $(MAKE) bump


.PHONY: test