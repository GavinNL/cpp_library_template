# This file creates project 'Foo' with two library targets 'bar' and 'baz'.
# Target 'bar' depends on 'baz'. After installation this project can be found
# by 'find_package(... CONFIG)' command:
#
#    find_package(Foo CONFIG REQUIRED)
#    target_link_libraries(... Foo::bar)
#
# Note that requirements propagated automatically, for example:
#   * Foo::baz linked automatically
#   * <prefix>/include added to header search path
#   * FOO_BAZ_DEBUG=1/FOO_BAR_DEBUG=1 added on Debug
#   * FOO_BAZ_DEBUG=0/FOO_BAR_DEBUG=0 added on other configurations

####
# Set minimum version of CMake.
cmake_minimum_required(VERSION 3.13) # GENERATOR_IS_MULTI_CONFIG

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


#-------------------------------------------------
# The base path where the include headers for this library will be stored relative
# to the root include path.
# For example: this project is named "bar"
#           the include path would be include/foo/bar
#
#-------------------------------------------------
set( PROJECT_BASE_INCLUDE_PATH  ${PROJECT_NAMESPACE}/${LIBRARY_NAME} )
#-------------------------------------------------

#-------------------------------------------------
# The target name that other libraries/execs will
# link to. it's okay to leave it as it us.
#-------------------------------------------------
set( ALIAS_TARGET_NAME   ${PROJECT_NAMESPACE}::${LIBRARY_NAME} )
#-------------------------------------------------

#-------------------------------------------------
# Set any linked targets we need. This library
# depends on foo::bar
#-------------------------------------------------
set( LINKED_TARGETS    )
#-------------------------------------------------


# You should list the source files here. You could automatically GLOB
# the source files, but it's not considered best practice
set( PROJECT_SOURCE_FILES  bar.cpp)


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



################################################################################
################################################################################

################################################################################



################################################################################
# Create Create the target library and its alias.
################################################################################

add_library( ${LIBRARY_NAME} ${PROJECT_SOURCE_FILES} )
add_library( ${ALIAS_TARGET_NAME}  ALIAS  ${LIBRARY_NAME}   )


target_link_libraries( ${LIBRARY_NAME} ${LINKED_TARGETS} )
################################################################################


####
# Properties of targets

string(TOUPPER "${LIBRARY_NAME}" LIBRARY_NAME_UPPERCASE)
string(TOUPPER "${PROJECT_NAMESPACE}" PROJECT_NAMESPACE_UPPERCASE)

# Add definitions for targets
# Values:
#   * Debug:   -DFOO_CAT_DEBUG=1
#   * Release: -DFOO_CAT_DEBUG=0
#   * other:   -DFOO_CAT_DEBUG=0
target_compile_definitions(${LIBRARY_NAME} PUBLIC "${PROJECT_NAMESPACE_UPPERCASE}_${LIBRARY_NAME_UPPERCASE}_DEBUG=$<CONFIG:Debug>")

# Generate:
#   * ${CMAKE_CURRENT_BINARY_DIR}/generated_headers/foo/BAR_EXPORT.h with BAR_EXPORT
#   * ${CMAKE_CURRENT_BINARY_DIR}/generated_headers/foo/BAZ_EXPORT.h with BAZ_EXPORT
# Renaming because:
# * We need prefix 'foo' to fit OSX/iOS frameworks layout
# * File name match name of the macro

set(generated_headers "${CMAKE_CURRENT_BINARY_DIR}/generated_headers")


string(TOUPPER "${LIBRARY_NAME}" export_file_name)


# set the export file path. This is used mostly by MVSC
#   EXPORT_FILE_PATH =
set( EXPORT_FILE_PATH  "${generated_headers}/${PROJECT_BASE_INCLUDE_PATH}/${export_file_name}_EXPORT.h" )

include(GenerateExportHeader)
generate_export_header( ${LIBRARY_NAME}
                            EXPORT_FILE_NAME    ${EXPORT_FILE_PATH}
                    )

# Global includes. Used by all targets
# Note:
#   * header location in project: foo/src/foo/bar.hpp
#   * header can be included by C++ code `#include <NAMESPACE/LIBRARY_NAME/header_file.h>`
#   * header location in project: ${CMAKE_CURRENT_BINARY_DIR}/generated_headers/NAMESPACE/LIBRARY_NAME/LIBRARY_NAME_export.h
#   * the exports header can be included by: `#include <NAMESPACE/LIBRARY_NAME/LIBRARY_NAME_export.h>`
target_include_directories(
    ${LIBRARY_NAME}
        PUBLIC
            "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>"
            "$<BUILD_INTERFACE:${generated_headers}>"
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
    DIRECTORY   "${CMAKE_SOURCE_DIR}/include/${PROJECT_BASE_INCLUDE_PATH}"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_BASE_INCLUDE_PATH}/.."
    FILES_MATCHING PATTERN "*"
)

# Export headers:
#   The export header will be stored in:
#            <prefix>/include/${NAMESPACE}/LIBRARY_NAME/LIBRARY_NAME_export.h
install(
    FILES
        "${EXPORT_FILE_PATH}"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_BASE_INCLUDE_PATH}"
)

# }
