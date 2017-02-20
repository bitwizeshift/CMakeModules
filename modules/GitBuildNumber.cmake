#.rst:
# GitBuildNumber
# ---------
#
# Gets the git build number
#
# Determines the git commit count to use as a build number
#
# ::
#
#     git_build_number( OUTPUT_VARIABLE )
#
#     OUTPUT_VARIABLE - The variable to store the result in
#
function(git_build_number _OUTPUT_VARIABLE)

  if( NOT GIT_EXECUTABLE_PATH )
    find_program(GIT_EXECUTABLE_PATH git)
  endif()

  if( GIT_EXECUTABLE_PATH )
    execute_process(COMMAND "${GIT_EXECUTABLE_PATH}" rev-list --count HEAD
                    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                    OUTPUT_VARIABLE "${_OUTPUT_VARIABLE}")

    set("${_OUTPUT_VARIABLE}" "${${_OUTPUT_VARIABLE}}" PARENT_SCOPE)
  else()
    set("${_OUTPUT_VARIABLE}" "${_OUTPUT_VARIABLE}-NOTFOUND" PARENT_SCOPE)
  endif()

endfunction()
