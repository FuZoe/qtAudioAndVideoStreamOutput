cmake_minimum_required(VERSION 3.16)

project(GrabToImage VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)


qt_add_executable(appGrabToImage
    main.cpp
)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_COMPILER "D:/Program Files/mingw64/bin/g++.exe")

set(FFMPEG_ROOT "C:/ffmpeg" CACHE PATH "FFmpeg 安装路径")

# 头文件路径
include_directories(${FFMPEG_ROOT}/include)

# 库文件路径
link_directories(${FFMPEG_ROOT}/lib)

find_package(PkgConfig REQUIRED)
pkg_check_modules(FFMPEG REQUIRED IMPORTED_TARGET
    libavutil
    libavcodec
    libavformat
    libswscale
    libswresample
    libavfilter
)


qt_add_qml_module(appGrabToImage
    URI GrabToImage
    VERSION 1.0
    QML_FILES
        Main.qml
    SOURCES
        videorecorder.h
        videorecorder.cpp
)



# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appGrabToImage PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appGrabToImage
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appGrabToImage
    PRIVATE Qt6::Quick
    PkgConfig::FFMPEG
)

target_link_libraries(appGrabToImage PRIVATE Qt6::Quick)

include(GNUInstallDirs)
install(TARGETS appGrabToImage
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)





