# C++ Library Template

This is a C++ Library Template using modern CMake. It's list file is modified
from https://github.com/forexample/package-example.


# Features

* Multimodule library. Two libraries wrapped in a single namespace: `foo::bar` and `foo::cat`
* Auto-generated EXPORT headers for Windows DLLs
* Auto-generated CMake config files for installation
* Unit tests
* **[to do]** CPack generation.
* **[to do]** Conan integration
* **[to do]** gitlab-ci, appveyor, travis integration


# Compiling

```Bash

git clone https://github.com/GavinNL/cpp_library_template
cd cpp_library_template
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/tmp/cpp_library_template -DBUILD_SHARED_LIBS:BOOL=TRUE
cmake --build .
ctest -C Debug
cmake --build . --target install

cd ..
rm -rf build
cd test_cmake_install

mkdir build && cd build
cmake .. -DCMAKE_PREFIX_PATH=/tmp/cpp_library_template
cmake --build .

export LD_LIBRARY_PATH=/tmp/cpp_library_template/lib
./test-bar
./test-cat

```
