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
SWITCH=jscoq+64bit
export WORD_SIZE=64
[ -d opam ] || (opam init --bare -y && opam switch create $SWITCH --packages ocaml-variants.4.12.0+options,dune.3.5.0,js_of_ocaml.4.0.0,ocamlfind,sexplib0.v0.14.0,elpi.1.16.8 -y)
eval $(opam env --switch=$SWITCH --set-switch)
opam repo add coq https://coq.inria.fr/opam/released
opam repo add overlay file://$PWD/opam-overlay

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
echo "export WORD_SIZE=64"
echo "eval \$(opam env --switch=$SWITCH --set-switch)"

##################################################################
# Coq

CLEAN=true

# Wacoq frontend
JSCOQ=_build/dist/jscoq-0.16.1
[ -d jscoq ] || CLEAN=false
# $CLEAN || (rm -rf jscoq; git clone git@github.com:gares/jscoq.git --recursive -b v8.15 && cd jscoq && npm install ../jscoq-bin/$WACOQ.tar.gz ../addons/*/jscoq-*.tgz)
$CLEAN || (rm -rf jscoq; git clone git@github.com:gares/jscoq.git --recursive -b v8.16 && cd jscoq && npm install && opam install --deps-only ./jscoq.opam -y)
[ -f jscoq/$JSCOQ.tgz ] || CLEAN=false
$CLEAN || (cd jscoq && make coq && make wacoq && make dist-npm)

[ -f $OPAMROOT/$SWITCH/bin/coqc ] || CLEAN=false
$CLEAN || (cd jscoq && make install)

# Wacoq libs / addons, also installed in opam/
$CLEAN || (cd addons ; rm -rf node_modules)
(cd addons; npm install jquery jszip ../jscoq/$JSCOQ.tgz)

[ -f addons/elpi/jscoq-elpi-*.tgz ] || CLEAN=false
$CLEAN || (cd addons/elpi && opam source coq-elpi.1.16.0 --dir=workdir && make && make install)

[ -f addons/hierarchy-builder/jscoq-hierarchy-builder-*.tgz ] || CLEAN=false
$CLEAN || (cd addons/hierarchy-builder && opam source coq-hierarchy-builder.1.4.0 --dir=workdir && make && make install)

[ -f addons/mathcomp/jscoq-mathcomp-*.tgz ] || CLEAN=false
$CLEAN || (cd addons/mathcomp && opam source coq-mathcomp-ssreflect.2.0.0+alpha1 --dir=workdir && make && make install)

[ -f addons/mczify/jscoq-mczify-*.tgz ] || CLEAN=false
$CLEAN || (cd addons/mczify && opam source coq-mathcomp-zify.hierarchy-builder --dir=workdir && make && make install)

[ -f addons/algebra-tactics/jscoq-algebra-tactics-*.tgz ] || CLEAN=false
$CLEAN || ( cd addons/algebra-tactics && opam source coq-mathcomp-algebra-tactics.hierarchy-builder --dir=workdir && make && make install)


# Archive to be unpacked in the wacoq worker file system

cd $OPAM_SWITCH_PREFIX/lib
for pkg in `ocamlfind list | grep ^coq- | cut -d ' ' -f 1`; do
    for p in `ocamlfind query $pkg -r -format '%+m %+a' -predicates byte`; do
        case ${p##$OPAM_SWITCH_PREFIX/lib/} in
          coq-core/plugins/*|coq-core/META)
            echo ${p##$OPAM_SWITCH_PREFIX/lib/};
          ;;
          coq-core/*)
            :
          ;;
          *)
            echo ${p##$OPAM_SWITCH_PREFIX/lib/};
          ;;
        esac;
    done;
done | xargs zip ../../../lib.zip
sed -i.bak '/directory/d' threads/META
cp ocaml/threads/threads.cma threads
echo seq/META | xargs zip ../../../lib.zip
echo threads/META threads/*.cma | xargs zip ../../../lib.zip
cd -

# To be deployed on the web server

cd deploy
rm -rf node_modules
npm install ../jscoq/$JSCOQ.tgz
npm install ../addons/*/jscoq-*.tgz
mkdir node_modules/scratch/ -p
cp ../lib.zip node_modules/scratch/

rm -f ../deploy-$V.tgz ; tar -czf ../deploy-$V.tgz .
