cmake_minimum_required(VERSION 3.16)

project(test0815-1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 查找Qt6
find_package(Qt6 REQUIRED COMPONENTS Core Widgets)

# 添加GStreamer包含路径
include_directories("D:/Program Files/MSY32/mingw64/include/gstreamer-1.0")
include_directories("D:/Program Files/MSY32/mingw64/include/glib-2.0")
include_directories("D:/Program Files/MSY32/mingw64/lib/glib-2.0/include")

# 添加可执行文件
add_executable(test0815-2 main.cpp)

# 链接Qt库
target_link_libraries(test0815-2 Qt6::Core Qt6::Widgets)

# 链接GStreamer库（假设库文件在同一目录的lib文件夹中）
target_link_libraries(test0815-2
    "D:/Program Files/MSY32/mingw64/lib/libgstreamer-1.0.dll.a"
    "D:/Program Files/MSY32/mingw64/lib/libgstvideo-1.0.dll.a"
    "D:/Program Files/MSY32/mingw64/lib/libglib-2.0.dll.a"
    "D:/Program Files/MSY32/mingw64/lib/libgobject-2.0.dll.a"
)

# 启用Qt的MOC（Meta-Object Compiler）
set_target_properties(test0815-2 PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    AUTOUIC ON
)

include(GNUInstallDirs)
install(TARGETS test0815-2
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# 在您的CMakeLists.txt中添加
if(WIN32)
    set(ENV{GST_DEBUG} "0")
    set(ENV{GST_DEBUG_DUMP_DOT_DIR} "")
endif()
