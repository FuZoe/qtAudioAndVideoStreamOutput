cmake_minimum_required(VERSION 3.16)

project(GrabToImage VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Multimedia)

# GStreamer dependencies
find_package(PkgConfig REQUIRED)
pkg_check_modules(GST REQUIRED gstreamer-1.0>=1.18 gstreamer-app-1.0 gstreamer-video-1.0)


qt_add_executable(appGrabToImage
    main.cpp
    GstStreamer.cpp
)

qt_add_qml_module(appGrabToImage
    URI GrabToImage
    VERSION 1.0
    QML_FILES
        Main.qml
        QML_FILES
        QML_FILES
        QML_FILES
        QML_FILES
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
            Qt6::Multimedia
            ${GST_LIBRARIES}
)

target_include_directories(appGrabToImage PRIVATE ${GST_INCLUDE_DIRS})
link_directories(${GST_LIBRARY_DIRS})

include(GNUInstallDirs)
install(TARGETS appGrabToImage
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
