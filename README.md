# C++ Library Template

This is a C++ Library Template using modern CMake. It's list file is modified
from https://github.com/forexample/package-example.


# Features

* Multimodule library: Three libraries wrapped in a single namespace: `foo::bar`, `foo::cat` and `food::dog`
* Auto-generated EXPORT headers for Windows DLLs
* Auto-generated CMake config files for installation
* Unit tests
* Conan Package Manager Integration
* Gitlab-CI integration
  * Builds the library with gcc/clang verions
  * Tests that the find_package() method works
  * Builds the Conan Package
  * Tests the cmake, cmake_paths, and cmake_find_package generators work
* **[to do]** CPack generation.


# Compiling

```Bash

# Build, test and install the library
git clone https://github.com/GavinNL/cpp_library_template
cd cpp_library_template
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/tmp/cpp_library_template -DBUILD_SHARED_LIBS:BOOL=TRUE
cmake --build .
ctest -C Debug
cmake --build . --target install

# Build an application that links to this one using.
# Use the find_package(foo) method to find where the installation
# is.
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
