# GNUstep Android Examples

This repository contains example projects to show how to use the [GNUstep Android Toolchain](https://github.com/gnustep/tools-android) in a project.

* [**hello-objectivec**](hello-objectivec)  
Android Studio project using CMake to compile Objective C code using GNUstep.  
The GNUstep integration can be found in [CMakeLists.txt](hello-objectivec/app/src/main/cpp/CMakeLists.txt).  
Additionaly, [GSInitialize.m](hello-objectivec/app/src/main/cpp/GSInitialize.m) shows how to initialize GNUstep and enables logging of stderr output via logcat.
* [**hello-objective-qt**](hello-objective-qt)  
Qt project using a custom compiler definition to support Objective C code using GNUstep.  
Can be run on Android as well as macOS.
