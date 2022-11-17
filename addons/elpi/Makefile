REPO = https://github.com/LPCIC/coq-elpi.git
TAG = v1.14.0
WORKDIR = workdir
GIT_CLONE = git clone --recursive --depth=1 -b $(TAG) $(REPO) $(WORKDIR)
define PKG
{
"name": "@wacoq/elpi",
"description": "coq-elpi",
"version": "$(TAG)",
"files": ["coq-pkgs"]
}
endef
export PKG

.PHONY: all get prepare

all: $(WORKDIR) prepare 
	# cp -r dune-files/* $(WORKDIR)/
	# must build plugin first
	# dune build $(WORKDIR)/src && dune build
	make -C $(WORKDIR) build APPS=
	npx wacoq build --workspace elpi.json
	echo "$$PKG" > package.json
	npm pack ./
	# rm -rf ../_build/$(CONTEXT)/elpi/
	# mkdir -p ../_build/$(CONTEXT)/elpi/
	# cp -r . ../_build/$(CONTEXT)/elpi/
	# cd ../_build/$(CONTEXT)/elpi; npx wacoq build --workspace elpi.json


prepare: $(WORKDIR)
	@echo '- Installing dependencies -'
	sed -i.bak '/"coq"/d' workdir/coq-elpi.opam  # don't install Coq
	unset DUNE_WORKSPACE && opam install -y --deps-only $(WORKDIR)/
	# node adjust_paths.js
	# linked by wacoq itself
	echo 'CAMLPKGS+=-dontlink result,ppx_deriving.runtime' >> $(WORKDIR)/Makefile.coq.local

get: $(WORKDIR)

$(WORKDIR):
	$(GIT_CLONE)
	#rm -f $(WORKDIR)/coq-builtin.elpi  # this file should not be there
	cd $(WORKDIR)/ && patch -p1 < ../disable-boot-init.diff

clean:
	make -C $(WORKDIR) clean APPS=
	rm -f $(WORKDIR)/Makefile.coq{,.conf}

install:
	# dune install coq-elpi
	make -C $(WORKDIR) install APPS=
