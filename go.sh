#!/bin/sh

[ -f node-v18.12.1-linux-x64.tar.xz ] || wget https://nodejs.org/dist/v18.12.1/node-v18.12.1-linux-x64.tar.xz
tar -xvJf node-v18.12.1-linux-x64.tar.xz
export PATH=$PATH:$PWD/node-v18.12.1-linux-x64/bin
which node

# git clone git@github.com:gares/wacoq-bin.git -b v8.15
# git clone git@github.com:gares/addon-elpi.git
# git clone git@github.com:gares/addon-mathcomp.git
# git clone git@github.com:gares/addons.git
# 
# opam switch delete