#.rst:
# EnableCCache
# ---------
#
# Enables ccache support in CMake
#
# This module defines the following functions:
#
# ::
#
#     enable_ccache()
#
# Enables ccache in the current project, if it's discovered
#
include(CMakeParseArguments)

macro(enable_ccache)

  set(__FIND_ROOT_PATH_MODE_PROGRAM ${CMAKE_FIND_ROOT_PATH_MODE_PROGRAM})
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

  find_program(CMAKE_CCACHE_PROGRAM ccache)

  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ${__FIND_ROOT_PATH_MODE_PROGRAM})
  set(__FIND_ROOT_PATH_MODE_PROGRAM)

  if(CMAKE_CCACHE_PROGRAM)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ${CMAKE_CCACHE_PROGRAM})
    set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ${CMAKE_CCACHE_PROGRAM})
  endif()

  mark_as_advanced(CMAKE_CCACHE_PROGRAM)

endmacro()
