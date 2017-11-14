#.rst:
# EnableIncludeWhatYouUse
# ---------
#
# Enables include-what-you-use (IWYU) support in CMake
#
# This module only works for CMake versions 3.4 or above; no error is
# emitted on anything lower, the module simply becomes a no-op
#
# ::
#
#     enable_iwyu( [LANGUAGES <language names>...]
#                  [ARGS <args to include-what-you-use>...] )
#
#     target_enable_iwyu( target
#                         [LANGUAGES <language names>...]
#                         [ARGS <args to include-what-you-use>...]  )
#
# The first form sets the iwyu language and arguments globally for all
# targets, the second form only enables it for the specified target
#

include(CMakeParseArguments)

# Don't bother searching unless we are using CMake version 3.6 or above
if( CMAKE_VERSION VERSION_GREATER 3.3 )
  find_program(INCLUDE_WHAT_YOU_USE_PATH NAMES include-what-you-use iwyu QUIET)
  mark_as_advanced(INCLUDE_WHAT_YOU_USE_PATH)
endif()


macro(enable_iwyu)
  if( NOT CMAKE_VERSION VERSION_GREATER 3.3 )
    return()
  endif()

  if( NOT INCLUDE_WHAT_YOU_USE_PATH )
    return()
  endif()

  message(STATUS "Enabling include-what-you-use")

  cmake_parse_arguments("__iwyu" "" "" "LANGUAGES;ARGS" ${ARGN})

  if( NOT __iwyu_LANGUAGES )
    set(__iwyu_LANGUAGES CXX) # default to C++ support
  endif()

  foreach( lang ${__iwyu_LANGUAGES} )
    set(CMAKE_${lang}_INCLUDE_WHAT_YOU_USE "${INCLUDE_WHAT_YOU_USE_PATH};${__iwyu_ARGS}")
  endforeach()

  set(CMAKE_INCLUDE_WHAT_YOU_USE_ENABLED On CACHE INTERNAL "")
  set(CMAKE_EXPORT_COMPILE_COMMANDS On)

  unset(__iwyu_LANGUAGES)
  unset(__iwyu_ARGS)

  message(STATUS "Enabling include-what-you-use - done")
endmacro()


macro(target_enable_iwyu target)
  if( NOT CMAKE_VERSION VERSION_GREATER 3.5 )
    return()
  endif()

  if( NOT INCLUDE_WHAT_YOU_USE_PATH )
    return()
  endif()

  cmake_parse_arguments("__iwyu" "" "" "LANGUAGES;ARGS" ${ARGN})

  if( NOT __iwyu_LANGUAGES )
    set(__iwyu_LANGUAGES CXX) # default to C++ support
  endif()

  foreach( lang ${__iwyu_LANGUAGES} )
    set_target_properties(${target} PROPERTY ${lang}_INCLUDE_WHAT_YOU_USE "${INCLUDE_WHAT_YOU_USE_PATH};${__iwyu_ARGS}")
  endforeach()

  unset(__iwyu_LANGUAGES)
  unset(__iwyu_ARGS)
endmacro()
