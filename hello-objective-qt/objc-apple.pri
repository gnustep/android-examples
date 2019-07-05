
XCODE_PATH = $$system(xcode-select -p)

osx {
    XCODE_SDK = 10.14
    XCODE_TARGET = 10.11

    QMAKE_CXXFLAGS += \
        -isysroot $${XCODE_PATH}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX$${XCODE_SDK}.sdk \
        -mmacosx-version-min=$$XCODE_TARGET \
}

LIBS += \
    -framework Foundation
