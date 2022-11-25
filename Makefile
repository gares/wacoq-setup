V=$(shell git describe --tags)

all:
	./go.sh $(V)

upload:
	echo 'cd /net/serveurs/www-sop/teams/marelle/MC-2022/;rm -rf *' | ssh roquableu.inria.fr
	scp deploy-$(V).tgz roquableu.inria.fr:/net/serveurs/www-sop/teams/marelle/MC-2022/
	echo 'cd /net/serveurs/www-sop/teams/marelle/MC-2022/;tar -xzf deploy-$(V).tgz' | ssh roquableu.inria.fr
	echo 'cd /net/serveurs/www-sop/teams/marelle/MC-2022/;chmod g+w --recursive . *' | ssh roquableu.inria.fr

distclean: clean
	rm -rf opam node-* wasi-*
	
clean:
	rm -rf jscoq wacoq-bin */node_modules lib.zip
	rm -rf addons/*/workdir addons/*/coq-pkgs addons/*/wacoq-*.tgz addons/*/package.json addons/package.json addons/package-lock.json
	rm -rf deploy/package.json deploy/package-lock.json

