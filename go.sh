#!/bin/sh
set -e
set -x

# ocaml-wasm wants 4.12
export OPAMROOT=$PWD/opam
[ -d opam ] || (opam init --bare -y && opam switch create wacoq --packages ocaml-variants.4.12.0+options,ocaml-option-32bit -y)
eval $(opam env --switch=wacoq --set-switch)

# Node 18 does not work
NODE=v16.15.0
[ -f node-$NODE-linux-x64.tar.xz ] || wget https://nodejs.org/dist/$NODE/node-$NODE-linux-x64.tar.xz
[ -d node-$NODE-linux-x64 ] || tar -xJf node-$NODE-linux-x64.tar.xz
export PATH=$PWD/node-$NODE-linux-x64/bin:$PATH
which node

# Wasi 12 is the one tested for wacoq 8.15
WASI=12.0
[ -f wasi-sdk-$WASI-linux.tar.gz ] || wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-12/wasi-sdk-$WASI-linux.tar.gz
[ -d wasi-sdk-$WASI ] || tar -xzf wasi-sdk-$WASI-linux.tar.gz
export WASI_SDK_PATH=$PWD/wasi-sdk-$WASI

CLEAN=true

# Wacoq backend (includes coq)
[ -d wacoq-bin ] || CLEAN=false
$CLEAN || (rm -rf wacoq-bin ; git clone git@github.com:gares/wacoq-bin.git -b v8.15 --recursive && cd wacoq-bin && npm install && make bootstrap && make coq)

[ -f wacoq-bin/wacoq-bin-0.15.1.tar.gz ] || CLEAN=false
$CLEAN || (cd wacoq-bin && make wacoq && make dist-npm)

[ -f $OPAMROOT/wacoq/bin/coqc ] || CLEAN=false
$CLEAN || (cd wacoq-bin && make install)

# Wacoq libs
[ -d addons ] || CLEAN=false
$CLEAN || (rm -rf addons; git clone git@github.com:gares/addons.git --recursive && cd addons && npm install jquery jszip ../wacoq-bin/wacoq-bin-0.15.1.tar.gz)

[ -f addons/_build/wacoq/wacoq-elpi-0.15.0.tgz ] || CLEAN=false
$CLEAN || (cd addons && make elpi)

[ -f addons/_build/wacoq/wacoq-hierarchy-builder-0.15.0.tgz ] || CLEAN=false
$CLEAN || (cd addons && make hierarchy-builder)

[ -f addons/_build/wacoq/wacoq-mathcomp-0.15.0.tgz ] || CLEAN=false
$CLEAN || (cd addons && make mathcomp)

[ -f addons/_build/wacoq/wacoq-mczify-0.15.0.tgz ] || CLEAN=false
$CLEAN || (cd addons && make mczify)

[ -f addons/_build/wacoq/wacoq-algebra-tactics-0.15.0.tgz ] || CLEAN=false
$CLEAN || (cd addons && make algebra-tactics)

$CLEAN || (cd addons && make pack)

# Wacoq frontend
[ -d jscoq ] || CLEAN=false
$CLEAN || (rm -rf jscoq; git clone git@github.com:gares/jscoq.git --recursive -b v8.15 && cd jscoq && npm install ../wacoq-bin/wacoq-bin-0.15.1.tar.gz ../addons/_build/wacoq/*tgz)

[ -f jscoq/wacoq-0.15.1.tgz ] || CLEAN=false
$CLEAN || (cd jscoq && make wacoq && make dist-npm-wacoq)

# Local deploy
cd deploy
rm -rf node_modules
npm install ../wacoq-bin/wacoq-bin-0.15.1.tar.gz
npm install ../jscoq/wacoq-0.15.1.tgz
npm install ../addons/_build/wacoq/wacoq-elpi-0.15.0.tgz
npm install ../addons/_build/wacoq/wacoq-hierarchy-builder-0.15.0.tgz
npm install ../addons/_build/wacoq/wacoq-mathcomp-0.15.0.tgz
npm install ../addons/_build/wacoq/wacoq-mczify-0.15.0.tgz
npm install ../addons/_build/wacoq/wacoq-algebra-tactics-0.15.0.tgz

tar -cvzf ../deploy.tgz .
cd ..
scp deploy.tgz roquableu.inria.fr:/net/serveurs/www-sop/teams/marelle/MC-2022/
ssh roquableu.inria.fr <<EOT
cd /net/serveurs/www-sop/teams/marelle/MC-2022/
tar -xzf deploy.tgz
EOT

#python3 -m http.server


# & google-chrome --allow-file-access-from-files --js-flags="--harmony-tailcalls" --js-flags="--stack-size=65536" ./index.html
