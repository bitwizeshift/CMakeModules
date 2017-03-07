#.rst:
# FindCatch
# ---------
#
# Find Catch
#
# Find Philsquared's "Catch" unit test library.
#
# ::
#
#     philsquared::Catch - Interface library target for the Catch headers
#     CATCH_FOUND        - TRUE if Catch was found
#     CATCH_INCLUDE_DIRS - The include path for catch headers
#
find_path(
  CATCH_INCLUDE_DIR
  NAMES "catch.hpp"
  DOC "Catch unit-test include directory"
)

set(CATCH_INCLUDE_DIRS ${CATCH_INCLUDE_DIR} CACHE FILEPATH "Include directory for the CATCH unit test")

# Create a custom Catch target if not already defined
if( NOT TARGET philsquared::Catch AND CATCH_INCLUDE_DIRS )

  add_library(philsquared::Catch INTERFACE IMPORTED)
  set_target_properties(philsquared::Catch PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${CATCH_INCLUDE_DIRS}
  )

endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(catch DEFAULT_MSG CATCH_INCLUDE_DIR)
mark_as_advanced(CATCH_INCLUDE_DIRS)
