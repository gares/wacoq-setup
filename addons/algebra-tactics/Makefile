WORKDIR = workdir
define PKG
{
"name": "@jscoq/algebra-tactics",
"description": "coq-mathcomp-algebra-tactics",
"version": "v0.0.0",
"files": ["coq-pkgs"]
}
endef
export PKG

.PHONY: all get prepare

all: $(WORKDIR) prepare
	make -C $(WORKDIR)
	npx jscoq build --workspace algebra-tactics.json
	echo "$$PKG" > package.json
	npm pack ./	

clean:
	make -C $(WORKDIR) clean
	rm -f $(WORKDIR)/Makefile.coq{,.conf}

install:
	make -C $(WORKDIR) install