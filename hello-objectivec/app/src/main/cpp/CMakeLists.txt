# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)

# Define list of Objective-C/C++ files

set(objectivec_SRCS GSInitialize.m ObjectiveCTest.mm)

# Set up Objective-C suppport via GNUstep

set(objectivec_COMPILE_FLAGS "-I$ENV{HOME}/Library/Android/GNUstep/include -fexceptions -fobjc-exceptions -D_NATIVE_OBJC_EXCEPTIONS -pthread -fPIC -DGSWARN -DGSDIAGNOSE -fobjc-runtime=gnustep-2.0 -fobjc-arc -fblocks -fconstant-string-class=NSConstantString")
set(objectivec_LINK_OPTIONS "-L$ENV{HOME}/Library/Android/GNUstep/lib -lgnustep-base -lobjc -ldispatch -lBlocksRuntime -lm")

set_property(SOURCE ${objectivec_SRCS}
        APPEND_STRING PROPERTY COMPILE_FLAGS ${objectivec_COMPILE_FLAGS})

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.

add_library( # Sets the name of the library.
        native-lib

        # Sets the library as a shared library.
        SHARED

        # Provides a relative path to your source file(s).
        native-lib.cpp ${objectivec_SRCS})

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

        # Add linker options for GNUstep
        ${objectivec_LINK_OPTIONS})

# Copy GNUstep libraries into output directory to be bundled with the app.

add_custom_command(TARGET native-lib POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        $ENV{HOME}/Library/Android/GNUstep/lib/*.so
        ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/)
