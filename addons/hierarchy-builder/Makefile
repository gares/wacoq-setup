REPO = https://github.com/math-comp/hierarchy-builder.git
TAG = v1.4.0
WORKDIR = workdir
define PKG
{
"name": "@wacoq/hierarchy-builder",
"description": "coq-hierarchy-builder",
"version": "$(TAG)",
"files": ["coq-pkgs"]
}
endef
export PKG

.PHONY: all get prepare

all: $(WORKDIR) prepare
	make -C $(WORKDIR) build
	npx wacoq build --workspace hierarchy-builder.json
	echo "$$PKG" > package.json
	npm pack ./

prepare: $(WORKDIR)

get: $(WORKDIR)

$(WORKDIR):
	git clone --depth=1 -b $(TAG) $(REPO) $(WORKDIR)

clean:
	make -C $(WORKDIR) clean
	rm -f $(WORKDIR)/Makefile.coq{,.conf}

install:
	make -C $(WORKDIR) install