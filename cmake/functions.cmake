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
            INCLUDE_PATHS)

    cmake_parse_arguments(
        PARSE_ARGV 0
        lib
        "${options}"
        "${args}"
        "${list_args}"
    )

    message(STATUS "arugment: ${lib_NAME}")
    message(STATUS "arugment: ${lib_SOURCES} ")
    message(STATUS "arugment: ${lib_NAMESPACE}")
    message(STATUS "arugment: ${lib_INCLUDE_PATHS}")

    add_library( ${lib_NAME} ${lib_SOURCES} )
    add_library( ${lib_NAMESPACE}::${lib_NAME}  ALIAS  ${lib_NAME}   )

    target_link_libraries( ${lib_NAME} PUBLIC ${lib_LINKED_TARGETS} )

    target_include_directories(  ${lib_NAME} PUBLIC ${lib_INCLUDE_PATHS})


    generate_export_header( ${lib_NAME}
                            EXPORT_FILE_NAME
                                ${lib_EXPORT_FILE_PATH}
                        )

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
