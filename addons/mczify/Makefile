REPO = https://github.com/proux01/mczify.git
TAG = hierarchy-builder
WORKDIR = workdir
define PKG
{
"name": "@wacoq/mczify",
"description": "coq-mathcomp-zify",
"version": "$(TAG)",
"files": ["coq-pkgs"]
}
endef
export PKG

.PHONY: all get prepare

all: $(WORKDIR) prepare
	make -C $(WORKDIR) VERBOSE=1
	npx wacoq build --workspace mczify.json
	echo "$$PKG" > package.json
	npm pack ./

	# rm -rf ../_build/$(CONTEXT)/mczify/ && cp -r . ../_build/$(CONTEXT)/mczify/
	# (cd ../_build/$(CONTEXT)/mczify; npx jscoq build --workspace mczify.json)

prepare: $(WORKDIR)

get: $(WORKDIR)

$(WORKDIR):
	git clone --depth=1 -b $(TAG) $(REPO) $(WORKDIR)
	#cd $(WORKDIR) && patch -p1 < ../disable-binary-nums.diff

clean:
	make -C $(WORKDIR) clean
	rm -f $(WORKDIR)/Makefile.coq{,.conf}

install:
	make -C $(WORKDIR) install