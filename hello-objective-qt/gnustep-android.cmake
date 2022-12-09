cmake_minimum_required(VERSION 3.18)

# set default GNUstep root directory
if (CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
	set(GNUSTEP_ROOT "$ENV{HOME}/Library/Android/GNUstep" CACHE FILEPATH "GNUstep Android root directory")
elseif (CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
	set(GNUSTEP_ROOT "$ENV{HOME}/Android/GNUstep" CACHE FILEPATH "GNUstep Android root directory")
else ()
	message(FATAL_ERROR "Unsupported platform")
endif ()

# add GNUstep root as prefix path
list(APPEND CMAKE_PREFIX_PATH ${GNUSTEP_ROOT}/${CMAKE_ANDROID_ARCH_ABI})

# find libraries

set(GNUSTEP_LIBRARY_NAMES
	objc
	charset
	iconv
	icuuc
	icui18n
	icudata
	gnustep-base
	gnustep-corebase
	dispatch
)

set(GNUSTEP_LIBRARY_PATHS)
foreach(lib IN LISTS GNUSTEP_LIBRARY_NAMES)
	find_library(LIB_${lib}
		NAMES ${lib}
		NO_CMAKE_FIND_ROOT_PATH
		REQUIRED)
	list(APPEND GNUSTEP_LIBRARY_PATHS ${LIB_${lib}})
endforeach()

# configure Objective-C(++) compiler

set(CMAKE_OBJC_FLAGS "-fobjc-runtime=gnustep-2.0 -fexceptions -fobjc-exceptions -fblocks -fobjc-arc")
set(CMAKE_OBJC_COMPILER_TARGET "${CMAKE_ANDROID_ARCH_TRIPLE}${CMAKE_SYSTEM_VERSION}")
set(CMAKE_OBJC_STANDARD_INCLUDE_DIRECTORIES "${GNUSTEP_ROOT}/${CMAKE_ANDROID_ARCH_ABI}/include")

set(CMAKE_OBJCXX_FLAGS ${CMAKE_OBJC_FLAGS})
set(CMAKE_OBJCXX_COMPILER_TARGET ${CMAKE_OBJC_COMPILER_TARGET})
set(CMAKE_OBJCXX_STANDARD_INCLUDE_DIRECTORIES ${CMAKE_OBJC_STANDARD_INCLUDE_DIRECTORIES})

# always link libobjc for CMake compiler detection to work
set(CMAKE_EXE_LINKER_FLAGS "${LIB_objc}")

# add defines required for GNUstep
add_compile_definitions(GNUSTEP GNUSTEP_BASE_LIBRARY=1 GNUSTEP_RUNTIME=1 _NONFRAGILE_ABI=1 _NATIVE_OBJC_EXCEPTIONS GSWARN GSDIAGNOSE)
