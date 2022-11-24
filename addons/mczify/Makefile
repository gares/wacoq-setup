REPO = https://github.com/proux01/mczify.git
TAG = hierarchy-builder
WORKDIR = workdir
define PKG
{
"name": "@jscoq/mczify",
"description": "coq-mathcomp-zify",
"version": "v0.0.0",
"files": ["coq-pkgs"]
}
endef
export PKG

.PHONY: all get prepare

all: $(WORKDIR) prepare
	make -C $(WORKDIR) VERBOSE=1
	npx jscoq build --workspace mczify.json
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