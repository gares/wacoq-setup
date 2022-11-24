#!/bin/sh
set -e
#set -x

V=$1
shift

####################################################################
# opam
#
# ocaml-wasm wants 4.12
export OPAMROOT=$PWD/opam
[ -d opam ] || (opam init --bare -y && opam switch create wacoq --packages ocaml-variants.4.12.0+options,ocaml-option-32bit,dune.3.5.0 -y)
eval $(opam env --switch=wacoq --set-switch)

###################################################################
# node
#
# Node 18 does not work
NODE=v16.15.0
[ -f node-$NODE-linux-x64.tar.xz ] || wget https://nodejs.org/dist/$NODE/node-$NODE-linux-x64.tar.xz
[ -d node-$NODE-linux-x64 ] || tar -xJf node-$NODE-linux-x64.tar.xz
export PATH=$PWD/node-$NODE-linux-x64/bin:$PATH
which node

##################################################################
# wasm SDK
#
# Wasi 12 is the one tested for wacoq 8.15
WASI=12.0
[ -f wasi-sdk-$WASI-linux.tar.gz ] || wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-12/wasi-sdk-$WASI-linux.tar.gz
[ -d wasi-sdk-$WASI ] || tar -xzf wasi-sdk-$WASI-linux.tar.gz
export WASI_SDK_PATH=$PWD/wasi-sdk-$WASI

echo "### To debug:"
echo "export OPAMROOT=$OPAMROOT"
echo "export PATH=$PATH"
echo "export WASI_SDK_PATH=$WASI_SDK_PATH"
echo 'eval $(opam env --switch=wacoq --set-switch)'

##################################################################
# Coq

CLEAN=true

# Wacoq backend, also installs coq in opam/
#
# hack, the URL of the website is hardcoded in wacoq-bin/src/backend/core.ts,
# replace it with file:/// to test locally (and rebuild)
[ -d wacoq-bin ] || CLEAN=false
# $CLEAN || (rm -rf wacoq-bin ; git clone git@github.com:gares/wacoq-bin.git -b v8.15 --recursive && cd wacoq-bin && npm install && make bootstrap && make coq)
$CLEAN || (rm -rf wacoq-bin ; git clone git@github.com:gares/wacoq-bin.git -b v8.16 --recursive && cd wacoq-bin && npm install && make bootstrap && make coq)

#WACOQ=wacoq-bin-0.15.1
WACOQ=wacoq-bin-0.16.0
[ -f wacoq-bin/$WACOQ.tar.gz ] || CLEAN=false
$CLEAN || (cd wacoq-bin && make wacoq && make dist-npm)

[ -f $OPAMROOT/wacoq/bin/coqc ] || CLEAN=false
$CLEAN || (cd wacoq-bin && make install)

# Wacoq libs / addons, also installed in opam/
$CLEAN || (cd addons ; rm -rf node_modules)
(cd addons; npm install jquery jszip ../wacoq-bin/$WACOQ.tar.gz)

[ -f addons/elpi/wacoq-elpi-*.tgz ] || CLEAN=false
$CLEAN || (cd addons/elpi && make && make install)

[ -f addons/hierarchy-builder/wacoq-hierarchy-builder-*.tgz ] || CLEAN=false
$CLEAN || (cd addons/hierarchy-builder && make && make install)

[ -f addons/mathcomp/wacoq-mathcomp-*.tgz ] || CLEAN=false
$CLEAN || (cd addons/mathcomp && make && make install)

[ -f addons/mczify/wacoq-mczify-*.tgz ] || CLEAN=false
$CLEAN || (cd addons/mczify && make && make install)

[ -f addons/algebra-tactics/wacoq-algebra-tactics-*.tgz ] || CLEAN=false
$CLEAN || (cd addons/algebra-tactics && make && make install)

# Wacoq frontend
JSCOQ=wacoq-0.16.0
[ -d jscoq ] || CLEAN=false
# $CLEAN || (rm -rf jscoq; git clone git@github.com:gares/jscoq.git --recursive -b v8.15 && cd jscoq && npm install ../wacoq-bin/$WACOQ.tar.gz ../addons/*/wacoq-*.tgz)
$CLEAN || (rm -rf jscoq; git clone git@github.com:gares/jscoq.git --recursive -b v8.16 && cd jscoq && npm install ../wacoq-bin/$WACOQ.tar.gz ../addons/*/wacoq-*.tgz && opam install dune.3.5.0 && opam install --deps-only ./jscoq.opam)

[ -f jscoq/$JSCOQ.tgz ] || CLEAN=false
$CLEAN || (cd jscoq && make wacoq && make dist-npm-wacoq)

# Archive to be deployed
cd deploy
rm -rf node_modules
npm install ../wacoq-bin/$WACOQ.tar.gz
npm install ../jscoq/$JSCOQ.tgz
npm install ../addons/*/wacoq-*.tgz

rm -f ../deploy-$V.tgz ; tar -czf ../deploy-$V.tgz .

#python3 -m http.server


# & google-chrome --allow-file-access-from-files --js-flags="--harmony-tailcalls" --js-flags="--stack-size=65536" ./index.html
