TAG = v1.16.0
WORKDIR = workdir
define PKG
{
"name": "@jscoq/elpi",
"description": "coq-elpi",
"version": "$(TAG)",
"files": ["coq-pkgs"]
}
endef
export PKG

.PHONY: all get prepare

all: $(WORKDIR) prepare 
	make -C $(WORKDIR) build APPS=
	npx jscoq build --workspace elpi.json
	echo "$$PKG" > package.json
	npm pack ./


prepare: $(WORKDIR)
	cd $(WORKDIR)/ && patch -p1 < ../disable-boot-init.diff
	@echo '- Installing dependencies -'
	sed -i.bak '/"coq"/d' workdir/coq-elpi.opam  # don't install Coq
	# sed -i.bak 's/coq-elpi.elpi/elpi_plugin:coq-elpi.elpi/' workdir/theories/elpi.v  # legacy loading
	unset DUNE_WORKSPACE && opam install -y --deps-only $(WORKDIR)/
	# echo 'CAMLPKGS+=-dontlink result,ppx_deriving.runtime' >> $(WORKDIR)/Makefile.coq.local

clean:
	make -C $(WORKDIR) clean APPS=
	rm -f $(WORKDIR)/Makefile.coq{,.conf}

install:
	# dune install coq-elpi
	make -C $(WORKDIR) install APPS=
