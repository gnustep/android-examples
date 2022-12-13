cmake_minimum_required(VERSION 3.18)

if (ANDROID)

	# set default GNUstep root directory where the GNUstep installation should be installed from:
	# https://github.com/gnustep/tools-android/releases
	if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
		set(GNUSTEP_ROOT "$ENV{HOME}/Library/Android/GNUstep" CACHE FILEPATH "GNUstep Android root directory")
	elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
		set(GNUSTEP_ROOT "$ENV{HOME}/Android/GNUstep" CACHE FILEPATH "GNUstep Android root directory")
	else()
		message(FATAL_ERROR "Unsupported platform")
	endif()

	set(GNUSTEP_HOME ${GNUSTEP_ROOT}/${CMAKE_ANDROID_ARCH_ABI})
	list(APPEND CMAKE_PREFIX_PATH ${GNUSTEP_HOME})

	# set flags

	foreach(lang IN ITEMS OBJC OBJCXX)
		set(CMAKE_${lang}_FLAGS "-fobjc-runtime=gnustep-2.0 -fexceptions -fobjc-exceptions -fblocks -fobjc-arc")
		set(CMAKE_${lang}_COMPILER_TARGET "${CMAKE_ANDROID_ARCH_TRIPLE}${CMAKE_SYSTEM_VERSION}")
		set(CMAKE_${lang}_STANDARD_INCLUDE_DIRECTORIES "${GNUSTEP_HOME}/include")
	endforeach()

	# add defines required by GNUstep

	add_compile_definitions(GNUSTEP GNUSTEP_BASE_LIBRARY=1 GNUSTEP_RUNTIME=1 _NONFRAGILE_ABI=1 _NATIVE_OBJC_EXCEPTIONS GSWARN GSDIAGNOSE)

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

	# always link libobjc for CMake compiler detection to work
	set(CMAKE_EXE_LINKER_FLAGS "${LIB_objc}")

elseif(WIN32)

	# set default GNUstep root directory where the GNUstep installation should be installed from:
	# https://github.com/gnustep/tools-windows-msvc/releases
	set(GNUSTEP_ROOT "C:/GNUstep" CACHE FILEPATH "GNUstep Windows MSVC root directory")

	set(GNUSTEP_HOME "${GNUSTEP_ROOT}/${MSVC_CXX_ARCHITECTURE_ID}/Release")
	list(APPEND CMAKE_PREFIX_PATH ${GNUSTEP_HOME})

	# set flags and work around Objective-C compiler detection issues on Windows

	foreach(lang IN ITEMS OBJC OBJCXX)
		set(CMAKE_${lang}_COMPILER_FORCED ON)
		foreach(runtimeLibrary IN ITEMS MultiThreaded MultiThreadedDLL MultiThreadedDebug MultiThreadedDebugDLL)
			set(CMAKE_${lang}_COMPILE_OPTIONS_MSVC_RUNTIME_LIBRARY_${runtimeLibrary} "")
		endforeach()

		set(CMAKE_${lang}_FLAGS "-fobjc-runtime=gnustep-2.0 -Xclang -fexceptions -Xclang -fobjc-exceptions -fblocks -Xclang -fobjc-arc")
		set(CMAKE_${lang}_STANDARD_INCLUDE_DIRECTORIES "${GNUSTEP_HOME}/include")
	endforeach()

	# add defines required by GNUstep

	add_compile_definitions(GNUSTEP GNUSTEP_WITH_DLL GNUSTEP_BASE_LIBRARY=1 GNUSTEP_RUNTIME=1 _NONFRAGILE_ABI=1 _NATIVE_OBJC_EXCEPTIONS GSWARN GSDIAGNOSE)

	# find libraries

	set(GNUSTEP_LIBRARY_NAMES
		objc
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

endif()
