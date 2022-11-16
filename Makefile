all:
	./go.sh

upload:
	echo 'cd /net/serveurs/www-sop/teams/marelle/MC-2022/;rm -rf *' | ssh roquableu.inria.fr
	scp deploy.tgz roquableu.inria.fr:/net/serveurs/www-sop/teams/marelle/MC-2022/
	echo 'cd /net/serveurs/www-sop/teams/marelle/MC-2022/;tar -xzf deploy.tgz' | ssh roquableu.inria.fr

clean:
	rm -rf opam jscoq wacoq-bin */node_modules deploy.tgz
	rm -rf addons/_build addons/*/workdir addons/package.json addons/package-lock.json
	rm -rf deploy/package.json deploy/package-lock.json

