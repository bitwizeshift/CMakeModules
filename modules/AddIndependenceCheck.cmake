cmake_minimum_required(VERSION 2.8.8)

#.rst:
# AddIndependenceCheck
# ---------
#
# Creates a C or C++ library that includes each specified header file
# independently to ensure that each header carries no expected ordering
#
# ::
#
#     add_independence_check( <target> [C|CXX] [headers]... )
#
#     <target>      - The name of the target to create
#     [C|CXX]       - The language check. By default, this is CXX
#     [headers]...  - List of headers to compile
#
function(add_independence_check target arg1)

  ############################### Setup output ###############################

  if( arg1 STREQUAL "C" ) # C
    set(headers ${ARGN})
    set(extension "c")
  elseif( arg1 STREQUAL "CXX" ) # CXX
    set(headers ${ARGN})
    set(extension "cpp")
  else()
    set(headers ${arg1} ${ARGN})
    set(extension "cpp")
  endif()

  set(output_dir "${CMAKE_CURRENT_BINARY_DIR}/src")

  ############################### Create files ###############################

  set(source_files)
  foreach( header ${headers} )

    get_filename_component(path_segment "${header}" PATH)
    get_filename_component(absolute_header "${header}" ABSOLUTE)
    file(RELATIVE_PATH relative_header "${output_dir}/${path_segment}" "${absolute_header}")

    set(output_path "${output_dir}/${header}.${extension}")

    if( NOT EXISTS "${output_path}" OR "${absolute_header}" IS_NEWER_THAN "${output_path}" )

      file(WRITE "${output_path}" "#include \"${relative_header}\"")

    endif()

    set_property( DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${fullpath}")

    list(APPEND source_files "${output_path}")

  endforeach()

  ######################## Create Independence Target ########################

  add_library("${target}" OBJECT ${source_files} ${headers})

endfunction()
