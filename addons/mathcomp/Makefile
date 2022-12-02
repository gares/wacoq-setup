
WORKDIR = workdir
define PKG
{
"name": "@jscoq/mathcomp",
"description": "coq-mathcomp-{ssreflect,fingroup,algebra,solvable,field}",
"version": "2.0.0",
"files": ["coq-pkgs"]
}
endef
export PKG

.PHONY: all get

all: $(WORKDIR)
	make -C $(WORKDIR)/mathcomp -j4
	npx jscoq build --workspace jscoq-mathcomp.json
	echo "$$PKG" > package.json
	npm pack ./

install:
	make -C $(WORKDIR)/mathcomp install
	# dune install ${addprefix coq-mathcomp-, ssreflect fingroup algebra solvable field character}
