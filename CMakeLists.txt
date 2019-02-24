#
# This is the Top level CMakelists file which creates the namespace and
# organizes all sublibraries under it.
#
# The project name in this file is considered the "Namespace"
# and any libraries under it will be given a target of
#
#  Namespace::library_name
#
#
# This Lists file was modified from https://github.com/forexample/package-example
#
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
# Set minimum version of CMake. We need 3.13 at least.
cmake_minimum_required(VERSION 3.13) # GENERATOR_IS_MULTI_CONFIG

################################################################################
# Set variables for the project. The:
#   * PROJECT_NAME
#   * PROJECT_VERSION
#   * PROJECT_NAMESPACE should be the same as the project.
project(foo VERSION 1.2.3)


set(PROJECT_NAMESPACE         foo  )  # The project namespace. Library targets
                                      # will be referred by
                                      # foo::bar. This value should usually be
                                      # the same as the project.
################################################################################



################################################################################
# Sub libraries.
#
#  Each sub library will be built as a static or shared library and a
#  target will be created for it.
#  for example, the bar libarry will have a target called foo::bar
################################################################################

# Macro to find all subdirectories.
MACRO(SUBDIRLIST result curdir)
  FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
  SET(dirlist "")
  FOREACH(child ${children})
    IF(IS_DIRECTORY ${curdir}/${child} )
      LIST(APPEND dirlist ${child})
    ENDIF()
  ENDFOREACH()
  SET(${result} ${dirlist})
ENDMACRO()

SUBDIRLIST(sub_modules "${CMAKE_CURRENT_SOURCE_DIR}/src")

FOREACH(subdir ${sub_modules})
 #message( "==== ${subdir} ====" )
 add_subdirectory(src/${subdir})
ENDFOREACH()

################################################################################




################################################################################
# Installation of the library and all it's sub components
################################################################################
# Get the Default installation folders:
# * CMAKE_INSTALL_LIBDIR
# * CMAKE_INSTALL_BINDIR
# * CMAKE_INSTALL_INCLUDEDIR
include(GNUInstallDirs)

# Layout. This works for all platforms:
#   * <prefix>/lib*/cmake/<PROJECT-NAME>
#   * <prefix>/lib*/
#   * <prefix>/include/
set(config_install_dir "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")

set(generated_dir                "${CMAKE_CURRENT_BINARY_DIR}/generated")

# Configuration
set(version_config "${generated_dir}/${PROJECT_NAME}ConfigVersion.cmake")
set(project_config "${generated_dir}/${PROJECT_NAME}Config.cmake")
set(TARGETS_EXPORT_NAME "${PROJECT_NAME}Targets")
set(namespace "${PROJECT_NAME}::")

# Include module with fuction 'write_basic_package_version_file'
include(CMakePackageConfigHelpers)

# Configure '<PROJECT-NAME>ConfigVersion.cmake'
# Use:
#   * PROJECT_VERSION
write_basic_package_version_file(
    "${version_config}" COMPATIBILITY SameMajorVersion
)

# Configure '<PROJECT-NAME>Config.cmake'
# Use variables:
#   * TARGETS_EXPORT_NAME
#   * PROJECT_NAME
configure_package_config_file(
    "cmake/Config.cmake.in"
    "${project_config}"
    INSTALL_DESTINATION "${config_install_dir}"
)

#Targets:
#  * <prefix>/lib/libbar.a
#  * <prefix>/lib/libbaz.a
#  * header location after install: <prefix>/include/foo/Bar.hpp
#  * headers can be included by C++ code `#include <foo/Bar.hpp>`
  install(
   TARGETS
       ${sub_modules}
   EXPORT
       "${TARGETS_EXPORT_NAME}"
   LIBRARY  DESTINATION "${CMAKE_INSTALL_LIBDIR}"
   ARCHIVE  DESTINATION "${CMAKE_INSTALL_LIBDIR}"
   RUNTIME  DESTINATION "${CMAKE_INSTALL_BINDIR}"
   INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
  )


# Config
#   * <prefix>/lib/cmake/Foo/FooConfig.cmake
#   * <prefix>/lib/cmake/Foo/FooConfigVersion.cmake
install(
    FILES
        "${project_config}" "${version_config}"
    DESTINATION
        "${config_install_dir}"
)

# Config
#   * <prefix>/lib/cmake/Foo/FooTargets.cmake
install(
    EXPORT
        "${TARGETS_EXPORT_NAME}"
    NAMESPACE
        "${namespace}"
    DESTINATION
        "${config_install_dir}"
)
