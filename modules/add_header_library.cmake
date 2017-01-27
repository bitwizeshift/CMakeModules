cmake_minimum_required(VERSION 2.6.3)

include("${CMAKE_CURRENT_LIST_DIR}/add_cxx_independence_test.cmake")

##############################################################################
# add_header_library
#-----------------------------------------------------------------------------
# Creates a CMake header (interface) library that performs a conformance check
#
# This is intended to be used for template/header libraries to compile
# syntactic validity of included header files
#
# Syntax:
#
# add_header_library( <target> [headers]... [INCLUDE_DIRECTORIES [directories]...] )
#
# <target>      : The name of the target to create
# [headers]...  : List of headers to compile
# [directories] : List of include directories that the headers exist in
#
# In order for the conformance check to compile, the include directories in 
# which the headers exist in must be specified.
#
# This implicitly adds the target_include_directories call
##############################################################################
function(add_header_library target)

  cmake_parse_arguments("" "" "" "INCLUDE_DIRECTORIES" ${ARGN})

  set(include_directories ${_INCLUDE_DIRECTORIES})
  set(headers ${_UNPARSED_ARGUMENTS})
  
  ######################## Create Interface Target #########################
  
  add_library(${target} INTERFACE)
  
  foreach( include_directory IN LISTS include_directories )
  
    target_include_directories(${target} INTERFACE "${include_directory}")
  
  endforeach()
  
  add_cxx_independence_test("${target}_independence_test" ${headers} INCLUDE_DIRECTORIES ${include_directories} DEPENDS ${target})

endfunction()