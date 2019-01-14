
MARKDOWNFILES:=$(shell find src/ -type f -name '*.md')
HTMLFILES:=$(shell find src/ -type f -name '*.html')
TMPHTML = $(MARKDOWNFILES:src/%.md=build/%/index.html) $(HTMLFILES:src/%.html=build/%/index.html)
OUTPUTHTML = $(TMPHTML:build/index/index.html=build/index.html)
RENDERDEPS=bin/render static/style.css

all: build

build/robots.txt:
	echo -e "User-agent: *\nAllow: /" > $@

build/index.html: src/index.md $(RENDERDEPS)
	@mkdir -p $(dir $@)
	bin/render $< > $@

build/%/index.html: src/%.md $(RENDERDEPS)
	@mkdir -p $(dir $@)
	bin/render $< > $@

build/%/index.html: src/%.html
	@mkdir -p $(dir $@)
	cp $< $@

build/static: $(shell find static/ -type f )
	mkdir -p build/
	cp -r static build/

build/favicon.ico: static/favicon.png
	convert $< $@

build/sitemap.xml: $(OUTPUTHTML)
	bin/sitemap $(OUTPUTHTML) > $@

build/atom.xml: $(OUTPUTHTML)
	bin/atom $(OUTPUTHTML) > $@

build: build/static $(OUTPUTHTML) build/robots.txt build/favicon.ico build/sitemap.xml build/atom.xml

serve:
	bin/serveit -s build "make -j8"

clean:
	rm -Rf build

help:
	@echo "make        # Builds the website into build/"
	@echo "make serve  # Starts a development server at http://localhost:8000/"
	@echo "make clean  # Deletes the build directory"

.DELETE_ON_ERROR:
.PHONY: all build clean serve help
