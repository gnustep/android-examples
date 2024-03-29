cmake_minimum_required(VERSION 3.18)

project(hello_objective_qt VERSION 1.0 LANGUAGES CXX) # NOT OBJC OBJCXX

include(objc-gnustep.cmake)

# enable Objective-C languages after including gnustep-android.cmake
enable_language(OBJC)
enable_language(OBJCXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(QT NAMES Qt6 REQUIRED COMPONENTS Core)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Gui Quick)

qt_standard_project_setup()

set(SOURCES
	main.cpp
	ObjC.m
	ObjCXX.mm
)
if(ANDROID)
	list(APPEND SOURCES GSInitialize.mm)
endif()

qt_add_executable(hello_objective_qt WIN32 MACOSX_BUNDLE ${SOURCES})

qt_add_resources(hello_objective_qt "qml"
	PREFIX "/"
	FILES "main.qml"
)

target_link_libraries(hello_objective_qt PRIVATE
    Qt::Core
    Qt::Gui
    Qt::Quick
)

if(ANDROID)
	target_link_libraries(hello_objective_qt PRIVATE
		android
		${GNUSTEP_LIBRARY_PATHS}
	)

    set_target_properties(hello_objective_qt PROPERTIES
		QT_ANDROID_EXTRA_LIBS "${GNUSTEP_LIBRARY_PATHS}"
	)
elseif(WIN32)
	target_link_libraries(hello_objective_qt PRIVATE
		${GNUSTEP_LIBRARY_PATHS}
	)
endif()

install(TARGETS hello_objective_qt
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
	LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

qt_generate_deploy_app_script(
	TARGET hello_objective_qt
    FILENAME_VARIABLE deploy_script
    NO_UNSUPPORTED_PLATFORM_ERROR
)
install(SCRIPT ${deploy_script})
