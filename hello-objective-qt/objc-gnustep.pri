android {
    equals(QMAKE_HOST.os, Darwin):{
        GNUSTEP_HOME="$$(HOME)/Library/Android/GNUstep/$$ANDROID_TARGET_ARCH"
    } else:equals(QMAKE_HOST.os, Linux):{
        GNUSTEP_HOME="$$(HOME)/Android/GNUstep/$$ANDROID_TARGET_ARCH"
    } else {
        error(Unsupported platform)
    }
}

GNUSTEP_CONFIG="$${GNUSTEP_HOME}/bin/gnustep-config"

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
    -lBlocksRuntime \

android {
    QT += androidextras
    LIBS += -landroid
    ANDROID_EXTRA_LIBS += $$files($${GNUSTEP_LIBRARIES_DIR}/*.so)
}

CONFIG(release, debug|release): \
    CLANG_FLAGS += $$system($$GNUSTEP_CONFIG --objc-flags)
else: \
    CLANG_FLAGS += $$system($$GNUSTEP_CONFIG --debug-flags)

QMAKE_LFLAGS += -Wl,--no-as-needed

CLANG_FLAGS += \
    -I$$[QT_HOST_PREFIX]/include \
    -I$$[QT_HOST_PREFIX]/include/QtCore \
    -I$$[QT_HOST_PREFIX]/include/QtQuick \
    -I$$[QT_HOST_PREFIX]/include/QtWidgets \
    -I$$[QT_HOST_PREFIX]/include/QtGui \
    -I$$[QT_HOST_PREFIX]/include/QtQml \
    -I$$[QT_HOST_PREFIX]/include/QtNetwork \

android {
    CLANG_FLAGS += \
        -I$$[QT_HOST_PREFIX]/include/QtAndroidExtras \

    # fix compatibility with NDK r20 (will be fixed in Qt 5.12.5 and 5.13.1)
    # https://bugreports.qt.io/browse/QTBUG-76293
    QMAKE_LFLAGS += -nostdlib++
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
clang_objc.commands = $${QMAKE_CC} $${QMAKE_CXXFLAGS} $${CLANG_FLAGS} $${CLANG_DEBUG_FLAGS} -Wall -Wno-unused-parameter -fobjc-arc -fPIC -o ${QMAKE_FILE_OUT} -c ${QMAKE_FILE_IN}

QMAKE_EXTRA_COMPILERS += clang_objc
