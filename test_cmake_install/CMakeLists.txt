cmake_minimum_required(VERSION 3.13) # GENERATOR_IS_MULTI_CONFIG

find_package(foo REQUIRED)

add_executable(main main.cpp)

target_link_libraries( main  foo::cat)
