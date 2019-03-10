#!/bin/bash

set -e
set -x

ln -s .ci-files/conan_server $HOME/.conan_server
conan_server &
sleep 3
