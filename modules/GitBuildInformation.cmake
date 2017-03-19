cmake_minimum_required(VERSION 3.1)

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
#                            [REF <hash>]
#                            [PATHSPECS <specs>...)
#
#     MINOR_VARIABLE <variable>  - The variable to store the minor number
#     PATCH_VARIABLE <variable>  - The variable to store the patch number
#     BUILD_VARIABLE <variable>  - The variable to store the build number
#     BRANCH_VARIABLE <variable> - The variable to store the minor number
#     REF <hash>                 - The git reference of the most recent major revision.
#                                  This may be an identifier, tag, or hash
#     PATHSPECS <specs>...       - The path specs to use for identifiers
#
macro(git_build_information)

  set(__single_args MINOR_VARIABLE PATCH_VARIABLE BUILD_VARIABLE BRANCH_VARIABLE REF)
  set(__multi_args PATHSPECS)
  cmake_parse_arguments("GIT" "" "${__single_args}" "${__multi_args}" "${ARGN}")

  if( NOT GIT_REF )
    message(FATAL_ERROR "git_build_information: REF not specified")
  endif()

  if( NOT GIT_EXECUTABLE_PATH )
    find_program(GIT_EXECUTABLE_PATH git)
  endif()

  if( NOT GIT_EXECUTABLE_PATH )
    if( GIT_MINOR_VARIABLE STREQUAL "" )
      set("${GIT_MINOR_VARIABLE}" "${GIT_MINOR_VARIABLE}-NOTFOUND")
    endif()
    if( GIT_PATCH_VARIABLE STREQUAL "" )
      set("${GIT_PATCH_VARIABLE}" "${GIT_PATCH_VARIABLE}-NOTFOUND")
    endif()
    if( GIT_BUILD_VARIABLE STREQUAL "" )
      set("${GIT_BUILD_VARIABLE}" "${GIT_BUILD_VARIABLE}-NOTFOUND")
    endif()
    if( GIT_BRANCH_VARIABLE STREQUAL "" )
      set("${GIT_BRANCH_VARIABLE}" "${GIT_BRANCH_VARIABLE}-NOTFOUND")
    endif()

    return()
  endif()

  if( NOT GIT_REF )
    set(_git_ref ${GIT_REF}..HEAD)
  else()
    set(_git_ref HEAD)
  endif()

  ############################## MINOR VERSION #############################

  if( GIT_MINOR_VARIABLE )

    execute_process(COMMAND "${GIT_EXECUTABLE_PATH}" rev-list --merges --count ${_git_ref} -- ${GIT_PATHSPECS}
                    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                    OUTPUT_VARIABLE "${GIT_MINOR_VARIABLE}"
                    ERROR_VARIABLE "${_error}"
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    ERROR_STRIP_TRAILING_WHITESPACE )

    if( _error )
      message(FATAL_ERROR "git_build_information: Error retrieving minor revision. ${_error}")
    endif()

  endif()

  ############################## PATCH VERSION #############################

  if( GIT_PATCH_VARIABLE )

    execute_process(COMMAND "${GIT_EXECUTABLE_PATH}" rev-list --min-parents=2 --max-count=1 ${_git_ref} -- ${GIT_PATHSPECS}
                    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                    OUTPUT_VARIABLE _recent_merge_commit
                    ERROR_VARIABLE "${_error}"
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    ERROR_STRIP_TRAILING_WHITESPACE )

    if( "${_recent_merge_commit}" STREQUAL "" )
      set(_recent_merge_commit ${GIT_REF})
    endif()

    execute_process(COMMAND "${GIT_EXECUTABLE_PATH}" rev-list --count ${_recent_merge_commit}..HEAD -- ${GIT_PATHSPECS}
                    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                    OUTPUT_VARIABLE "${GIT_PATCH_VARIABLE}"
                    ERROR_VARIABLE "${_error}"
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    ERROR_STRIP_TRAILING_WHITESPACE )

    set(_recent_merge_commit)

    if( _error )
      message(FATAL_ERROR "git_build_information: Error retrieving patch revision. ${_error}")
    endif()

  endif()

  ############################## BUILD VERSION #############################

  if( GIT_BUILD_VARIABLE )

    execute_process(COMMAND "${GIT_EXECUTABLE_PATH}" rev-list --count HEAD -- ${GIT_PATHSPECS}
                    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                    OUTPUT_VARIABLE "${GIT_BUILD_VARIABLE}"
                    ERROR_VARIABLE "${_error}"
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    ERROR_STRIP_TRAILING_WHITESPACE )

    if( _error )
      message(FATAL_ERROR "git_build_information: Error retrieving build number. ${_error}")
    endif()

  endif()

  ############################## BRANCH NAME ###############################

  if( GIT_BRANCH_VARIABLE )

    execute_process(COMMAND "${GIT_EXECUTABLE_PATH}" rev-parse --abbrev-ref HEAD
                    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                    OUTPUT_VARIABLE "${GIT_BRANCH_VARIABLE}"
                    ERROR_VARIABLE "${_error}"
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    ERROR_STRIP_TRAILING_WHITESPACE )

    if( _error )
      message(FATAL_ERROR "git_build_information: Error retrieving build number. ${_error}")
    endif()

  endif()

endmacro()
