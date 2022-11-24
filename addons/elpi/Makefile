REPO = https://github.com/LPCIC/coq-elpi.git
TAG = v1.16.0
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
	make -C $(WORKDIR) build APPS=
	npx wacoq build --workspace elpi.json
	echo "$$PKG" > package.json
	npm pack ./


prepare: $(WORKDIR)
	@echo '- Installing dependencies -'
	sed -i.bak '/"coq"/d' workdir/coq-elpi.opam  # don't install Coq
	sed -i.bak 's/coq-elpi.plugin/elpi_plugin:coq-elpi.plugin/' workdir/theories/elpi.v  # legacy loading
	unset DUNE_WORKSPACE && opam install -y --deps-only $(WORKDIR)/
	echo 'CAMLPKGS+=-dontlink result,ppx_deriving.runtime -linkall' >> $(WORKDIR)/Makefile.coq.local

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
