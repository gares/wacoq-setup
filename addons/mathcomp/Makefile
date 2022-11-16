
REPO = https://github.com/math-comp/math-comp.git
TAG = hierarchy-builder
WORKDIR = workdir

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
	# cp -r dune-files/* $(WORKDIR)/
	# dune build
	make -C $(WORKDIR)/mathcomp -j4
	rm -rf ../_build/$(CONTEXT)/mathcomp/ && cp -r . ../_build/$(CONTEXT)/mathcomp/
	(cd ../_build/$(CONTEXT)/mathcomp; npx wacoq build --workspace jscoq-mathcomp.json)

get: $(WORKDIR)

$(WORKDIR):
	$(GIT_CLONE)
	#( cd $(WORKDIR) && git apply ../mathcomp-fast-load.patch )
	#sed -i.bak 's?solvable/burnside_app.v??' $(WORKDIR)/mathcomp/Make


install:
	make -C $(WORKDIR)/mathcomp install
	# dune install ${addprefix coq-mathcomp-, ssreflect fingroup algebra solvable field character}
