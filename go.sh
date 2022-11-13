#!/bin/sh
set -e
set -x

export OPAMROOT=$PWD/opam
[ -d opam ] || (opam init --bare -y && opam switch create wacoq --packages ocaml-variants.4.12.0+options,ocaml-option-32bit -y)
eval $(opam env --switch=wacoq --set-switch)

# Node 18 does not work
NODE=v16.15.0
[ -f node-$NODE-linux-x64.tar.xz ] || wget https://nodejs.org/dist/$NODE/node-$NODE-linux-x64.tar.xz
tar -xJf node-$NODE-linux-x64.tar.xz
export PATH=$PWD/node-$NODE-linux-x64/bin:$PATH
which node

WASI=12.0
[ -f wasi-sdk-$WASI-linux.tar.gz ] || wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-12/wasi-sdk-$WASI-linux.tar.gz
tar -xzf wasi-sdk-$WASI-linux.tar.gz
export WASI_SDK_PATH=$PWD/wasi-sdk-$WASI

[ -d wacoq-bin ] || (git clone git@github.com:gares/wacoq-bin.git -b v8.15 --recursive && cd wacoq-bin && npm install && make bootstrap && make coq)
[ -f wacoq-bin/wacoq-bin-0.15.1.tar.gz ] || (cd wacoq-bin && make wacoq && make dist-npm && make install)

[ -d addons ] || (git clone git@github.com:gares/addons.git --recursive && cd addons && npm install && npm install ../wacoq-bin/wacoq-bin-0.15.1.tar.gz)
(cd addons && make world)
