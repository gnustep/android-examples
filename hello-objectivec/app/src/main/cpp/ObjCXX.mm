#import "ObjCXX.h"

#include <jni.h>

#define APPNAME "helloobjectivec"

@implementation TestCXX

+ (void)initialize
{
    NSLog(@"%@ %@", self, NSStringFromSelector(_cmd));
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"%@ %@", self, NSStringFromSelector(_cmd));
    }
    return self;
}

- (NSString *)test
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"Hello NSString from %@", self];

    [string appendString:@"\n\nAssets resources:"];
    [string appendFormat:@"\n- Info.plist app name: %@", [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
    [string appendFormat:@"\n- Info.plist app version: %@", [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    [string appendFormat:@"\n- Localized string: %@ %@", NSLocalizedString(@"LocalizedString", nil), NSBundle.mainBundle.localizations];

    NSArray *array = [NSArray arrayWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"Array" ofType:@"plist" inDirectory:@"Subfolder"]];
    [string appendFormat:@"\n- Plist array: %@", [array componentsJoinedByString:@", "]];

    return [string copy];
}

- (void)throwException
{
    [NSException raise:NSInternalInconsistencyException format:@"Testing Objective-C exception from -[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
}

- (void)dealloc
{
    NSLog(@"%@ %@", self, NSStringFromSelector(_cmd));
}

@end

extern "C" JNIEXPORT jstring JNICALL
Java_com_example_helloobjectivec_MainActivity_stringFromObjectiveC(JNIEnv *env, jobject /* this */)
{
    NSString *nsString = [[[TestCXX alloc] init] test];
    const char *cString = [nsString cStringUsingEncoding:NSString.defaultCStringEncoding];
    return env->NewStringUTF(cString);
}

extern "C" JNIEXPORT void JNICALL
Java_com_example_helloobjectivec_MainActivity_throwObjCXXException(JNIEnv *env, jobject /* this */)
{
    [[[TestCXX alloc] init] throwException];
}
