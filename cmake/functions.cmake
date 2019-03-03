include(GenerateExportHeader)

MACRO(directory_list result curdir)
    FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
    SET(dirlist "")
    FOREACH(child ${children})
        IF(IS_DIRECTORY ${curdir}/${child} )
            LIST(APPEND dirlist ${child})
        ENDIF()
    ENDFOREACH()
    SET(${result} ${dirlist})
ENDMACRO()

function(create_library)
    set(options)
    set(args NAME
             NAMESPACE
             EXPORT_FILE_PATH
             )

    set(list_args
            LINKED_TARGETS
            SOURCES
            PUBLIC_DEFINITIONS
            PRIVATE_DEFINITIONS
            PUBLIC_INCLUDE_PATHS
            PRIVATE_INCLUDE_PATHS
            INCLUDE_PATHS)

    cmake_parse_arguments(
        PARSE_ARGV 0
        lib
        "${options}"
        "${args}"
        "${list_args}"
    )

    # message(STATUS "arugment: ${lib_NAME}")
    # message(STATUS "arugment: ${lib_SOURCES} ")
    # message(STATUS "arugment: ${lib_NAMESPACE}")
    # message(STATUS "arugment: ${lib_INCLUDE_PATHS}")

    if("${lib_NAME}" STREQUAL "")
        get_filename_component(lib_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
        string(REPLACE " " "_" lib_NAME ${lib_NAME})
        message(" Library, NAME argument not provided. Using folder name:  ${lib_NAME}")
    endif()

    if("${lib_NAMESPACE}" STREQUAL "")
        set(lib_NAMESPACE ${lib_NAME})
        message(" Library, NAMESPACE argument not provided. Using target alias:  ${lib_NAME}::${lib_NAME}")
    endif()

    add_library( ${lib_NAME} ${lib_SOURCES} )
    add_library( ${lib_NAMESPACE}::${lib_NAME}  ALIAS  ${lib_NAME}   )

    target_link_libraries( ${lib_NAME} PUBLIC ${lib_LINKED_TARGETS} )

    target_include_directories( ${lib_NAME}
                                PUBLIC
                                    ${lib_INCLUDE_PATHS}
                                    ${lib_PUBLIC_INCLUDE_PATHS}
                                PRIVATE
                                    ${lib_PRIVATE_INCLUDE_PATHS}
                                )

    target_compile_definitions( ${lib_NAME}
                                PUBLIC
                                    ${lib_PUBLIC_DEFINITIONS}
                                PRIVATE
                                    ${lib_PRIVATE_DEFINITIONS}
                               )

    if( NOT "${lib_EXPORT_FILE_PATH}" STREQUAL "" )
        generate_export_header( ${lib_NAME}
                                EXPORT_FILE_NAME
                                    ${lib_EXPORT_FILE_PATH}
                            )
    endif()

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
################################################################################
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

    foreach(arg IN LISTS lib_UNPARSED_ARGUMENTS)
        message(WARNING "Unparsed argument: ${arg}")
    endforeach()

endfunction()
