android {
    versionAtLeast(QT_VERSION, "5.14.0"): ANDROID_ARCH = $$QT_ARCH
    else: ANDROID_ARCH = $$ANDROID_TARGET_ARCH

    equals(QMAKE_HOST.os, Darwin): GNUSTEP_HOME = "$$(HOME)/Library/Android/GNUstep/$$ANDROID_ARCH"
    else:equals(QMAKE_HOST.os, Linux): GNUSTEP_HOME = "$$(HOME)/Android/GNUstep/$$ANDROID_ARCH"
    else: error(Unsupported platform)
}

GNUSTEP_CONFIG = "$${GNUSTEP_HOME}/bin/gnustep-config"

!exists($$GNUSTEP_CONFIG) {
    error(GNUstep config not found at $${GNUSTEP_CONFIG}. \
        Please install the GNUstep Android toolchain from \
        https://github.com/gnustep/tools-android)
}

GNUSTEP_LIBRARIES_FLAGS = $$system($$GNUSTEP_CONFIG --base-libs)
GNUSTEP_LIBRARIES_DIR = $$system($$GNUSTEP_CONFIG --variable=GNUSTEP_SYSTEM_LIBRARIES)

INCLUDEPATH += "$$(GNUSTEP_HOME)/include"

LIBS += \
    $$GNUSTEP_LIBRARIES_FLAGS \
    -lgnustep-corebase \
    -ldispatch \

android {
    LIBS += -landroid
	equals(QT_MAJOR_VERSION, 5): QT += androidextras

    equals(QT_MAJOR_VERSION, 5):versionAtLeast(QT_VERSION, "5.14.0") {
        # add libraries from all architectures
        for(abi, $$list($$ANDROID_ABIS)) {
            equals(QMAKE_HOST.os, Darwin): GNUSTEP_ARCH_HOME = "$$(HOME)/Library/Android/GNUstep/$$abi"
            else:equals(QMAKE_HOST.os, Linux): GNUSTEP_ARCH_HOME = "$$(HOME)/Android/GNUstep/$$abi"
            GNUSTEP_ARCH_CONFIG = "$${GNUSTEP_ARCH_HOME}/bin/gnustep-config"
            GNUSTEP_ARCH_LIBRARIES_DIR = $$system($$GNUSTEP_ARCH_CONFIG --variable=GNUSTEP_SYSTEM_LIBRARIES)
            GNUSTEP_LIBS = $$files($${GNUSTEP_ARCH_LIBRARIES_DIR}/*.so)

            # ICU libraries need to be loaded before all others
            ICU_LIBS = \
                $${GNUSTEP_ARCH_LIBRARIES_DIR}/libicuuc.so \
                $${GNUSTEP_ARCH_LIBRARIES_DIR}/libicui18n.so \
                $${GNUSTEP_ARCH_LIBRARIES_DIR}/libicudata.so
            GNUSTEP_LIBS -= $${ICU_LIBS}
            ANDROID_EXTRA_LIBS += $${ICU_LIBS} $${GNUSTEP_LIBS}
        }
    } else {
        GNUSTEP_LIBS = $$files($${GNUSTEP_LIBRARIES_DIR}/*.so)

        # ICU libraries need to be loaded before all others
        ICU_LIBS = \
            $${GNUSTEP_LIBRARIES_DIR}/libicuuc.so \
            $${GNUSTEP_LIBRARIES_DIR}/libicui18n.so \
            $${GNUSTEP_LIBRARIES_DIR}/libicudata.so
        GNUSTEP_LIBS -= $${ICU_LIBS}
        ANDROID_EXTRA_LIBS += $${ICU_LIBS} $${GNUSTEP_LIBS}
    }
}

CONFIG(release, debug|release): \
    QMAKE_OBJECTIVE_CFLAGS += $$system($$GNUSTEP_CONFIG --objc-flags)
else: \
    QMAKE_OBJECTIVE_CFLAGS += $$system($$GNUSTEP_CONFIG --debug-flags)

QMAKE_LFLAGS += -Wl,--no-as-needed

android {
    equals(QT_MAJOR_VERSION, 5): CLANG_FLAGS += -I$$[QT_HOST_PREFIX]/include/QtAndroidExtras

    # work around NDK r20 compatibility (fixed with Qt 5.14)
    # https://bugreports.qt.io/browse/QTBUG-76293
    !versionAtLeast(QT_VERSION, "5.14.0"): QMAKE_LFLAGS += -nostdlib++
}

for(i, INCLUDEPATH) {
    CLANG_FLAGS += -I"$$absolute_path($${i}, .)"  # second argument is where includes live relative to this .pri
}

for(i, DEFINES) {
    CLANG_FLAGS += -D$${i}
}

CONFIG(debug, debug|release) || CONFIG(force_debug_info): CLANG_DEBUG_FLAGS = -g

clang_objc.input = OBJECTIVE_SOURCES
clang_objc.dependency_type = TYPE_C
clang_objc.variable_out = OBJECTS
clang_objc.output = ${QMAKE_VAR_OBJECTS_DIR}${QMAKE_FILE_IN_BASE}$${first(QMAKE_EXT_OBJ)}
clang_objc.commands = $(if $(filter ${QMAKE_FILE_EXT}, .mm), $(CXX) -c $(CXXFLAGS), $(CC) -c $(CFLAGS)) $${QMAKE_OBJECTIVE_CFLAGS} $(INCPATH) -o ${QMAKE_FILE_OUT} ${QMAKE_FILE_IN}

QMAKE_EXTRA_COMPILERS += clang_objc
