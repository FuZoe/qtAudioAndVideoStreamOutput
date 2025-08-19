# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\test0815-2_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\test0815-2_autogen.dir\\ParseCache.txt"
  "test0815-2_autogen"
  )
endif()
