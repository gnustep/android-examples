# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)

# Define list of Objective-C/C++ files

set(OBJECTIVEC_SRCS GSInitialize.m ObjC.m ObjCXX.mm)

# Set up Objective-C suppport via GNUstep

if (CMAKE_HOST_APPLE)
    set(GNUSTEP_HOME "$ENV{HOME}/Library/Android/GNUstep/${ANDROID_ABI}")
elseif(CMAKE_HOST_UNIX)
    set(GNUSTEP_HOME "$ENV{HOME}/Android/GNUstep/${ANDROID_ABI}")
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

set(GNUSTEP_CONFIG "${GNUSTEP_HOME}/bin/gnustep-config")

if (NOT EXISTS ${GNUSTEP_CONFIG})
    message(FATAL_ERROR "GNUstep config not found at ${GNUSTEP_CONFIG}.\n"
        "Please install the GNUstep Android toolchain from\n"
        "https://github.com/gnustep/tools-android")
endif()

# get options from gnustep-config
execute_process(COMMAND ${GNUSTEP_CONFIG} --debug-flags # or --objc-flags
        OUTPUT_VARIABLE OBJECTIVEC_COMPILE_FLAGS
        OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND ${GNUSTEP_CONFIG} --base-libs
        OUTPUT_VARIABLE OBJECTIVEC_LINK_OPTIONS
        OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND ${GNUSTEP_CONFIG} --variable=GNUSTEP_SYSTEM_LIBRARIES
        OUTPUT_VARIABLE OBJECTIVEC_LIBRARIES_DIR
        OUTPUT_STRIP_TRAILING_WHITESPACE)

# enable Automatic Reference Counting
set(OBJECTIVEC_COMPILE_FLAGS "${OBJECTIVEC_COMPILE_FLAGS} -fobjc-arc")

# add CoreFoundation and libdispatch
set(OBJECTIVEC_LINK_OPTIONS "${OBJECTIVEC_LINK_OPTIONS} -lgnustep-corebase -ldispatch")

# set compile flags on Objective-C/C++ files
set_property(SOURCE ${OBJECTIVEC_SRCS}
        APPEND_STRING PROPERTY COMPILE_FLAGS ${OBJECTIVEC_COMPILE_FLAGS})

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.

add_library( # Sets the name of the library.
        native-lib

        # Sets the library as a shared library.
        SHARED

        # Provides a relative path to your source file(s).
        ${OBJECTIVEC_SRCS})

# Searches for a specified prebuilt library and stores the path as a
# variable. Because CMake includes system libraries in the search path by
# default, you only need to specify the name of the public NDK library
# you want to add. CMake verifies that the library exists before
# completing its build.

find_library( # Sets the name of the path variable.
        log-lib

        # Specifies the name of the NDK library that
        # you want CMake to locate.
        log)

# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.

target_link_libraries( # Specifies the target library.
        native-lib

        # Links the target library to the log library
        # included in the NDK.
        ${log-lib}

        # Link Android native application APIs
        android

        # Add linker options for GNUstep
        ${OBJECTIVEC_LINK_OPTIONS})

# Copy GNUstep libraries into output directory to be bundled with the app.

add_custom_command(TARGET native-lib POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${OBJECTIVEC_LIBRARIES_DIR}/*.so
        ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/)
