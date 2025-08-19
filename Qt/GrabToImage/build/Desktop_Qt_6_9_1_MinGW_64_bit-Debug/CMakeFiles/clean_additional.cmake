# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\appGrabToImage_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\appGrabToImage_autogen.dir\\ParseCache.txt"
  "appGrabToImage_autogen"
  )
endif()
