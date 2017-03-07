cmake_minimum_required(VERSION 3.1.3)

include(CMakeParseArguments)

#.rst:
# MakeVersionHeader
# ---------
#
# Makes a version header
#
# ::
#
#     make_version_header( <header path>
#                          MAJOR <major>
#                          MINOR <minor>
#                          PATCH <patch>
#                          BUILD <build>
#                          PREFIX <prefix>
#                         [SUFFIX <suffix>]
#                         [TAG <tag>] )
#
#     <header path>   - The header path
#     MAJOR <major>   - The major version number
#     MINOR <minor>   - The minor version number
#     PATCH <patch>   - The patch version number
#     BUILD <build>   - The build number (optional)
#     SUFFIX <suffix> - The version suffix
#     TAG <tag>       - A tag identifier for the current build flow. Often
#                       a branch name
#
macro(make_version_header output_path )

  set(args ${ARGN})
  list(LENGTH args size)

  if( size LESS 10 )
    message(FATAL_ERROR "make_version_header: Incorrect number of arguments")
  endif()

  ############################ Default Arguments #############################

  set(MAJOR_VERSION)
  set(MINOR_VERSION)
  set(PATCH_VERSION)
  set(BUILD_NUMBER)
  set(PREFIX "")
  set(TAG_VERSION "")
  set(VERSION_SUFFIX "")
  set(VERSION_TAG)
  set(VERSION_STRING "")
  set(FULL_VERSION_STRING "")

  ############################ Required Arguments ############################

  list(GET args 0 major)
  list(GET args 1 MAJOR_VERSION)
  list(GET args 2 minor)
  list(GET args 3 MINOR_VERSION)
  list(GET args 4 patch)
  list(GET args 5 PATCH_VERSION)
  list(GET args 6 build)
  list(GET args 7 BUILD_NUMBER)
  list(GET args 8 prefix)
  list(GET args 9 PREFIX)

  ######################## Validate Required Arguments #######################

  if( NOT major STREQUAL "MAJOR" )
    message(FATAL_ERROR "make_version_header: Incorrect positional argument 1. Expected 'MAJOR', received '${major}'")
  endif()
  if( NOT MAJOR_VERSION MATCHES "[0-9]+")
    message(FATAL_ERROR "make_version_header: Incorrect major version. Expected numeric entry, received '${MAJOR_VERSION}'")
  endif()
  if( NOT minor STREQUAL "MINOR" )
    message(FATAL_ERROR "make_version_header: Incorrect positional argument 3. Expected 'MINOR', received '${minor}'")
  endif()
  if( NOT MINOR_VERSION MATCHES "[0-9]+")
    message(FATAL_ERROR "make_version_header: Incorrect minor version. Expected numeric entry, received '${MINOR_VERSION}'")
  endif()
  if( NOT patch STREQUAL "PATCH" )
    message(FATAL_ERROR "make_version_header: Incorrect positional argument 5. Expected 'PATCH', received '${patch}'")
  endif()
  if( NOT PATCH_VERSION MATCHES "[0-9]+")
    message(FATAL_ERROR "make_version_header: Incorrect patch version. Expected numeric entry, received '${PATCH_VERSION}'")
  endif()
  if( NOT build STREQUAL "BUILD" )
    message(FATAL_ERROR "make_version_header: Incorrect positional argument 7. Expected 'BUILD', received '${build}'")
  endif()
  if( NOT BUILD_NUMBER MATCHES "[0-9]+")
    message(FATAL_ERROR "make_version_header: Incorrect build number. Expected numeric entry, received '${BUILD_NUMBER}'")
  endif()
  if( NOT prefix STREQUAL "PREFIX" )
    message(FATAL_ERROR "make_version_header: Incorrect positional argument 9. Expected 'PREFIX', received '${prefix}'")
  endif()

  ############################ Optional Arguments ############################

  set(VERSION_SUFFIX "")
  set(TAG_VERSION "")
  if( size GREATER 11 )
    list(GET args 10 suffix_or_tag)
    list(GET args 11 suffix_or_tag_value)
    if( suffix_or_tag STREQUAL "SUFFIX" )
      set(VERSION_SUFFIX "${suffix_or_tag_value}")
    elseif( suffix_or_tag STREQUAL "TAG" )
      set(TAG_VERSION "${suffix_or_tag_value}")
    else()
      message(FATAL_ERROR "make_version_header: Incorrect positional argument 7. Expected either 'SUFFIX' or 'TAG', received '${suffix_or_tag}'")
    endif()

  endif()
  if( size EQUAL 14 )
    if( NOT TAG_VERSION STREQUAL "" )
      message(FATAL_ERROR "make_version_header: TAG specified twice.")
    endif()

    list(GET args 12 tag)
    list(GET args 13 TAG_VERSION)

    if( NOT tag STREQUAL "TAG" )
      message(FATAL_ERROR "make_version_header: Incorrect positional argument 12. Expected 'TAG', received '${tag}'")
    endif()
  endif()

  ############################ Template Generation ###########################

  set(template_file "${CMAKE_CURRENT_BINARY_DIR}/MakeVersionHeader/version.h.in")
  if( NOT EXISTS "${template_file}" )
    file(WRITE "${template_file}"
"
/// Major version of this library
#define @PREFIX@VERSION_MAJOR        @MAJOR_VERSION@

/// Minor version of this library
#define @PREFIX@VERSION_MINOR        @MINOR_VERSION@

/// Patch version of this library
#define @PREFIX@VERSION_PATCH        @PATCH_VERSION@

/// The version suffix
#define @PREFIX@VERSION_SUFFIX       @VERSION_SUFFIX@

/// The current build number
#define @PREFIX@BUILD_NUMBER         @BUILD_NUMBER@

/// The tag name for this (normally a branch name)
#define @PREFIX@VERSION_TAG          \"@TAG_VERSION@\"

/// The version string (major.minor.patch)
#define @PREFIX@VERSION_STRING       \"@VERSION_STRING@\"

/// The full version string (major.minor.patch (tag build))
#define @PREFIX@VERSION_STRING_FULL  \"@FULL_VERSION_STRING@\"
")
  endif()

  ############################### Configuring ################################

  if(PREFIX)
    string(TOUPPER "${PREFIX}" PREFIX)
    set(PREFIX "${PREFIX}_")
  endif()

  set(VERSION_STRING "${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}")

  if( TAG_VERSION )
    set(FULL_VERSION_STRING "${VERSION_STRING}${VERSION_SUFFIX} (${TAG_VERSION} ${BUILD_NUMBER})")
  else()
    set(FULL_VERSION_STRING "${VERSION_STRING}${VERSION_SUFFIX}")
  endif()

  configure_file("${template_file}" "${output_path}" @ONLY)

endmacro()
