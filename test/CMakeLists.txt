################################################################################
# This CMakeLists.txt contains the build descriptions for unit tests
################################################################################

cmake_minimum_required(VERSION 3.13.0 FATAL_ERROR)


#-------------------------------------------------------------------------------
# Test for the add( ) function
# These are just redundant examples, in we should probably loop over all the
# files and compile them
#-------------------------------------------------------------------------------
set(UNIT_TEST_SOURCE_FILE unit-foo.cat.cpp)
set(UNIT_TEST_EXE_NAME    unit-foo.cat)
set(UNIT_TEST_NAME        unit-foo.cat)
set(UNIT_TEST_LINK_LIBS   foo::cat )
#-------------------------------------------------------------------------------

add_executable( ${UNIT_TEST_EXE_NAME}   ${UNIT_TEST_SOURCE_FILE})

# Tell the executable that we build that we need to link with the
# math::math target
target_link_libraries( ${UNIT_TEST_EXE_NAME}  ${UNIT_TEST_LINK_LIBS})

add_test( ${UNIT_TEST_NAME}  ${UNIT_TEST_EXE_NAME})
#-------------------------------------------------------------------------------
