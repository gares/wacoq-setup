REPO = https://github.com/proux01/algebra-tactics.git
TAG = hierarchy-builder
WORKDIR = workdir
define PKG
{
"name": "@wacoq/algebra-tactics",
"description": "coq-mathcomp-algebra-tactics",
"version": "v0.0.0",
"files": ["coq-pkgs"]
}
endef
export PKG

.PHONY: all get prepare

all: $(WORKDIR) prepare
	make -C $(WORKDIR)
	npx wacoq build --workspace algebra-tactics.json
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