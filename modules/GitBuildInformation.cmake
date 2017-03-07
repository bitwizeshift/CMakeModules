cmake_minimum_required(VERSION 2.6.3)

include(CMakeParseArguments)

#.rst:
# GitBuildInformation
# ---------
#
# Gets build information from a git repository
#
# Determines the git commit count to use as a build number
#
# ::
#
#     git_build_information( [MINOR_VARIABLE <variable>]
#                            [PATCH_VARIABLE <variable>]
#                            [BUILD_VARIABLE <variable>]
#                            [BRANCH_VARIABLE <variable>]
#                            [HASH <hash>] )
#
#     MINOR_VARIABLE <variable> - The variable to store the minor number
#     PATCH_VARIABLE <variable> - The variable to store the patch number
#     BUILD_VARIABLE <variable> - The variable to store the build number
#     BRANCH_VARIABLE <variable> - The variable to store the minor number
#     HASH <hash> - The git hash of the most recent major revision
#
macro(git_build_information )

  set(__single_args MINOR_VARIABLE PATCH_VARIABLE BUILD_VARIABLE BRANCH_VARIABLE HASH)
  cmake_parse_arguments("GIT" "" "${__single_args}" "${ARGN}")

  if( NOT "${GIT_HASH}" )
    message(FATAL_ERROR "git_build_information: HASH not specified")
  endif()

  if( NOT GIT_EXECUTABLE_PATH )
    find_program(GIT_EXECUTABLE_PATH git)
  endif()

  if( GIT_EXECUTABLE_PATH )

    execute_process(COMMAND "${GIT_EXECUTABLE_PATH}" rev-list --merges --count ${GIT_HEAD}..HEAD
                    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                    OUTPUT_VARIABLE "${GIT_MINOR_VARIABLE}"
                    ERROR_VARIABLE "${_error}")

    if( _error )
      message(FATAL_ERROR "git_build_information: Error retrieving minor revision. ${_error}")
    endif()

    execute_process(COMMAND "${GIT_EXECUTABLE_PATH}" rev-list --count ${GIT_HASH}..HEAD
                    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                    OUTPUT_VARIABLE "${GIT_PATCH_VARIABLE}"
                    ERROR_VARIABLE "${_error}")

    if( _error )
      message(FATAL_ERROR "git_build_information: Error retrieving patch revision. ${_error}")
    endif()

    execute_process(COMMAND "${GIT_EXECUTABLE_PATH}" rev-list --count HEAD
                    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                    OUTPUT_VARIABLE "${GIT_BUILD_VARIABLE}")

    if( _error )
      message(FATAL_ERROR "git_build_information: Error retrieving build number. ${_error}")
    endif()

  else()

    set("${GIT_MINOR_VARIABLE}" "GIT_MINOR_VARIABLE-NOTFOUND")
    set("${GIT_PATCH_VARIABLE}" "GIT_PATCH_VARIABLE-NOTFOUND")
    set("${GIT_BUILD_VARIABLE}" "GIT_BUILD_VARIABLE-NOTFOUND")

  endif()

endmacro()
