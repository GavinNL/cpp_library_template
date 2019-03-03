# This file creates project 'Foo' with two library targets 'bar' and 'baz'.
# Target 'bar' depends on 'baz'. After installation this project can be found
# by 'find_package(... CONFIG)' command:
#
#    find_package(Foo CONFIG REQUIRED)
#    target_link_libraries(... Foo::bar)
#


####
# Set minimum version of CMake.
cmake_minimum_required(VERSION 3.13)

################################################################################
# Set variables:
#   * PROJECT_NAME
#   * PROJECT_VERSION
#
#  You may modify these variables.
################################################################################
#-------------------------------------------------
# Use the folder name as the library/project name.
# If you do not want to do that, set LIBRARY_NAME
# to something else.
#-------------------------------------------------
get_filename_component(LIBRARY_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(REPLACE " " "_" LIBRARY_NAME ${LIBRARY_NAME})
#-------------------------------------------------
project(${LIBRARY_NAME}
        VERSION
            1.2.3)

 create_library(NAME  dog
                NAMESPACE foo
                SOURCES
                    dog.cpp
                LINKED_TARGETS
                    foo::cat
                INCLUDE_PATHS
                    "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>"
                    "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/generated_headers>"
                EXPORT_FILE_PATH
                    "${CMAKE_CURRENT_BINARY_DIR}/generated_headers/foo/dog/DOG_EXPORT.h"
 )

 # Introduce variables:
 # * CMAKE_INSTALL_LIBDIR
 # * CMAKE_INSTALL_BINDIR
 # * CMAKE_INSTALL_INCLUDEDIR
 include(GNUInstallDirs)

 # Headers:
 #   * include/foo/bar/bar.h -> <prefix>/include/NAMESPACE/LIBRARY_NAME/*.h
 #   * include/foo/bar/bar.h -> <prefix>/include/foo/bar/bar.h
 install(
     DIRECTORY   "${CMAKE_SOURCE_DIR}/include/foo/dog"
     DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/foo/"
     FILES_MATCHING PATTERN "*"
 )

 # Export headers:
 #   The export header will be stored in:
 #            <prefix>/include/${NAMESPACE}/LIBRARY_NAME/LIBRARY_NAME_export.h
 install(
     FILES
         "${CMAKE_CURRENT_BINARY_DIR}/generated_headers/foo/dog/DOG_EXPORT.h"
     DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/foo/dog"
 )

################################################################################


# Debug Information Format:
# * https://docs.microsoft.com/en-us/cpp/build/reference/z7-zi-zi-debug-information-format
#
# Notes:
#
# * /Z7 still produce PDB file for DLL and without the PDB file installed
#   you can't debug DLL
#
# * /Z7 for static library doesn't produce PDB. It's the best option if you
#   want debug library without changing internal CMake code.
#   Toolchain example: https://github.com/ruslo/polly/blob/master/vs-15-2017-win64-z7.cmake
#
# * /Zi option is default (produce separate PDB files)
#
# * TARGET_PDB_FILE generator expression doesn't support static libraries.
#   See https://gitlab.kitware.com/cmake/cmake/issues/16932
#   (that's why it's not used here)
#
# * This code can be implemented as a 'PDB DESTINATION' feature.
#   See https://gitlab.kitware.com/cmake/cmake/issues/16935#note_275180
#
# * By default only Debug/RelWithDebInfo produce debug information,
#   Release/MinSizeRel do not.
#
# * Generated PDB for static libraries doesn't respect CMAKE_<CONFIG>_POSTFIX
#   variable. It means if you specify Debug and RelWithDebInfo then generated
#   PDB files for both will be "md5.pdb". When PDB files installed one will
#   overwrite another making it unusable. Release + Debug configurations will
#   work fine because Release doesn't produce PDB files.
#
# * All PDB files will be installed, including PDB for targets that will not
#   be installed themselves.

if(MSVC)
  set(pdb_output_dir "${CMAKE_CURRENT_BINARY_DIR}/pdb-files")

  set(CMAKE_PDB_OUTPUT_DIRECTORY "${pdb_output_dir}")
  set(CMAKE_COMPILE_PDB_OUTPUT_DIRECTORY "${pdb_output_dir}")

  get_cmake_property(is_multi GENERATOR_IS_MULTI_CONFIG)
  if(is_multi)
    set(config_suffix "$<CONFIG>")
  else()
    set(config_suffix "")
  endif()

  # Introduce variables:
  # * CMAKE_INSTALL_LIBDIR
  # * CMAKE_INSTALL_BINDIR
  include(GNUInstallDirs)

  if(BUILD_SHARED_LIBS)
    set(pdb_dst ${CMAKE_INSTALL_BINDIR})
  else()
    set(pdb_dst ${CMAKE_INSTALL_LIBDIR})
  endif()

  install(
      DIRECTORY "${pdb_output_dir}/${config_suffix}/"
      DESTINATION ${pdb_dst}
  )
endif()




# }
