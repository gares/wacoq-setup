TAG = v1.4.0
WORKDIR = workdir
define PKG
{
"name": "@jscoq/hierarchy-builder",
"description": "coq-hierarchy-builder",
"version": "$(TAG)",
"files": ["coq-pkgs"]
}
endef
export PKG

.PHONY: all get prepare

all: $(WORKDIR) prepare
	make -C $(WORKDIR) build
	npx jscoq build --workspace hierarchy-builder.json
	echo "$$PKG" > package.json
	npm pack ./

clean:
	make -C $(WORKDIR) clean
	rm -f $(WORKDIR)/Makefile.coq{,.conf}

install:
	make -C $(WORKDIR) install