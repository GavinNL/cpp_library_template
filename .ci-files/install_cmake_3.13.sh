#!/bin/bash

set -e
set -x

if [[ "$(uname -s)" == 'Darwin' ]]; then
    echo "Darwin!"
fi

wget -q https://github.com/Kitware/CMake/releases/download/v3.13.4/cmake-3.13.4-Linux-x86_64.tar.gz -O cmake.tar.gz
tar -xzf cmake.tar.gz -C cmake_ext
cp -r cmake_ext/* /
