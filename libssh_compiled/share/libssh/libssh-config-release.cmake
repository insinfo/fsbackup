#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "ssh" for configuration "Release"
set_property(TARGET ssh APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(ssh PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/ssh.lib"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/ssh.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS ssh )
list(APPEND _IMPORT_CHECK_FILES_FOR_ssh "${_IMPORT_PREFIX}/lib/ssh.lib" "${_IMPORT_PREFIX}/bin/ssh.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
