REPO = https://github.com/math-comp/hierarchy-builder.git
TAG = v1.4.0
WORKDIR = workdir

.PHONY: all get prepare

all: $(WORKDIR) prepare
	make -C $(WORKDIR) build
	rm -rf ../_build/$(CONTEXT)/hierarchy-builder/ && cp -r . ../_build/$(CONTEXT)/hierarchy-builder/
	(cd ../_build/$(CONTEXT)/hierarchy-builder; npx wacoq build --workspace hierarchy-builder.json)

prepare: $(WORKDIR)

get: $(WORKDIR)

$(WORKDIR):
	git clone --depth=1 -b $(TAG) $(REPO) $(WORKDIR)

clean:
	make -C $(WORKDIR) clean
	rm -f $(WORKDIR)/Makefile.coq{,.conf}

install:
	make -C $(WORKDIR) install