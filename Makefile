all:
	./go.sh

clean:
	rm -rf opam jscoq wacoq-bin */node_modules deploy.tgz
	rm -rf addons/_build addons/*/workdir addons/package.json addons/package-lock.json
	rm -rf deploy/package.json deploy/package-lock.json

