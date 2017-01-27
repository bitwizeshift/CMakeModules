cmake_minimum_required(VERSION 2.6.3)

##############################################################################
# add_cxx_independence_test
#-----------------------------------------------------------------------------
# Creates a C++ library that includes each specified header file independently
# to ensure that each header carries no expected ordering
#
# Syntax:
#
# add_cxx_independence_test( <target> [headers]...
#                            [INCLUDE_DIRECTORIES [directories]...]
#                            [DEPENDENCIES [target]...] )
#
# <target>      : The name of the target to create
# [headers]...  : List of headers to compile
# [directories] : List of include directories that the headers exist in
#
# In order for the conformance check to compile, the include directories in
# which the headers exist in must be specified.
##############################################################################
function(add_cxx_independence_test target)

  cmake_parse_arguments("" "" "" "DEPENDS;INCLUDE_DIRECTORIES" ${ARGN})

  set(include_directories ${_INCLUDE_DIRECTORIES})
  set(headers ${_UNPARSED_ARGUMENTS})
  set(targets ${_DEPENDS})

  set(tmp_dir "${CMAKE_CURRENT_BINARY_DIR}/src")

  ############################## Create files ##############################

  set(source_files)
  foreach( header IN LISTS headers )

    get_filename_component(absolute_header "${header}" ABSOLUTE)

    foreach( include_directory IN LISTS include_directories )

      get_filename_component(absolute_include_directory "${include_directory}" ABSOLUTE)

      string(LENGTH "${absolute_include_directory}" size)
      string(SUBSTRING "${absolute_header}" 0 ${size} path)

      if( path STREQUAL "${absolute_include_directory}" )

        file(RELATIVE_PATH relative_header "${absolute_include_directory}" "${absolute_header}")

        set(output_path "${tmp_dir}/${relative_header}.cpp")

        if( NOT EXISTS "${output_path}" OR "${absolute_header}" IS_NEWER_THAN "${output_path}" )

          file(WRITE "${output_path}" "#include <${relative_header}>")

          get_filename_component(fullpath "${file}" ABSOLUTE)
          set_property( DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${fullpath}")

        endif()

        list(APPEND source_files "${output_path}")
        break()

      endif()

    endforeach()

  endforeach()

  ######################### Create a sanity target #########################

  add_library("${target}" OBJECT ${source_files} ${headers})

  foreach( tgt IN LISTS targets )

    target_include_directories("${target}" PRIVATE "$<TARGET_PROPERTY:${tgt},INTERFACE_INCLUDE_DIRECTORIES>")
    target_include_directories("${target}" SYSTEM PRIVATE "$<TARGET_PROPERTY:${tgt},INTERFACE_SYSTEM_INCLUDE_DIRECTORIES>")
    target_compile_options("${target}" PRIVATE "$<TARGET_PROPERTY:${tgt},INTERFACE_COMPILE_DEFINITIONS>")
    target_compile_options("${target}" PRIVATE "$<TARGET_PROPERTY:${tgt},INTERFACE_COMPILE_OPTIONS>")

  endforeach()

endfunction()
