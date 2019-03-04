################################################################################
# This CMakeLists.txt contains the build descriptions for unit tests
################################################################################

cmake_minimum_required(VERSION 3.13.0 FATAL_ERROR)

#===============================================================================
# add_unit_test
#
# add_unit_test( NAME  test-foo.cat        # Name for the unit test
#                SOURCE                    # The sources that will be compiled [optional]
#                     unit-foo.cat.cpp
#                LINK_TARGETS              # The targest that need to be linked to this unit test [optional]
#                     foo::cat
#                EXE_NAME                  # The output name of the executable [optional]
#                     unit-foo.cat         #   defaults to NAME.exe
#                COMMAND                   # The command and arguments to be called. [optional]
#                     unit-foo.cat         #   defaults to Name.exe
#                )
#===============================================================================
function(add_unit_test)
    set(options)
    set(args NAME SOURCE EXE_NAME)

    set(list_args LINK_TARGETS COMMAND)
    cmake_parse_arguments(
        PARSE_ARGV 0
        test
        "${options}"
        "${args}"
        "${list_args}"
    )

    # message(STATUS "arugment: ${test_NAME}")
    # message(STATUS "arugment: ${test_SOURCE} ")
    # message(STATUS "arugment: ${test_TEST_ARGV}")

    if( NOT "${test_SOURCE}" STREQUAL "" )

        if( "${test_EXE_NAME}" STREQUAL "" )
                set( test_EXE_NAME  "${test_NAME}.exe")
        endif()

        message("Compiling test: ${test_EXE_NAME}   sources ${test_SOURCE}")
        add_executable( ${test_EXE_NAME}  ${test_SOURCE} )
        target_link_libraries( ${test_EXE_NAME}  ${test_LINK_TARGETS} )

        if( "${test_COMMAND}" STREQUAL "" )
            set(test_COMMAND "${test_EXE_NAME}")
        endif()

    endif()

    #if( NOT "${OUT_CMD}" STREQUAL "" )
        message("Adding Test: ${test_NAME}    cmd: ${test_COMMAND}")
        add_test(  NAME
                      ${test_NAME}
                   COMMAND
                      ${test_COMMAND}
                 )
    #endif()

    foreach(arg IN LISTS test_UNPARSED_ARGUMENTS)
        message(WARNING "Unparsed argument: ${arg}")
    endforeach()

endfunction()
#===============================================================================


add_unit_test( NAME  test-foo.cat        # Name for the unit test
               SOURCE                    # The sources that will be compiled [optional]
                    unit-foo.cat.cpp
               LINK_TARGETS              # The targest that need to be linked to this unit test [optional]
                    foo::cat
               EXE_NAME
                    unit-foo.cat
               COMMAND                   # The command to be called.
                    unit-foo.cat
               )

add_unit_test( NAME  test-foo.bar       # Name for the unit test
              SOURCE                    # The sources that will be compiled [optional]
                   unit-foo.bar.cpp
              LINK_TARGETS              # The targest that need to be linked to this unit test [optional]
                   foo::cat
#              EXE_NAME                 # The executable file to produce
#                   unit-foo.cat        #       defaults to test-foo.bar.exe
#              COMMAND                  # The command to be called.
#                   unit-foo.cat        #       defaults to test-foo.bar.exe
              )

  add_unit_test(NAME test-dir       # Name for the unit test
                COMMAND                  # The command to be called.
                     ls -lath
                )
