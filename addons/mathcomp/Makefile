
REPO = https://github.com/math-comp/math-comp.git
TAG = hierarchy-builder
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

SUBPKGS = ssreflect fingroup character field solvable algebra all

# Git boilerplate
define GIT_CLONE_COMMIT
mkdir -p $(WORKDIR) && cd $(WORKDIR) && git init && \
git remote add origin $(REPO) && \
git fetch --depth=1 origin $(COMMIT) && git reset --hard FETCH_HEAD
endef
GIT_CLONE = ${if $(COMMIT), $(GIT_CLONE_COMMIT), git clone --recursive --depth=1 -c advice.detachedHead=false -b $(TAG) $(REPO) $(WORKDIR)}

.PHONY: all get

all: $(WORKDIR)
	make -C $(WORKDIR)/mathcomp -j4
	npx jscoq build --workspace jscoq-mathcomp.json
	echo "$$PKG" > package.json
	npm pack ./

get: $(WORKDIR)

$(WORKDIR):
	$(GIT_CLONE)

install:
	make -C $(WORKDIR)/mathcomp install
	# dune install ${addprefix coq-mathcomp-, ssreflect fingroup algebra solvable field character}
