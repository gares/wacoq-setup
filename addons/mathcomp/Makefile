
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
	cp -r dune-files/* $(WORKDIR)/
	dune build

get: $(WORKDIR)

$(WORKDIR):
	$(GIT_CLONE)
	( cd $(WORKDIR) && git apply ../mathcomp-fast-load.patch )

install:
	dune install ${addprefix coq-mathcomp-, ssreflect fingroup algebra solvable field character}
