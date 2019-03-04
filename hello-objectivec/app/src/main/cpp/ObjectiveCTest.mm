#import "ObjectiveCTest.h"

#include <jni.h>

#define APPNAME "helloobjectivec"

extern "C" JNIEXPORT jstring JNICALL
Java_com_example_helloobjectivec_MainActivity_stringFromObjectiveC(
        JNIEnv *env,
        jobject /* this */) {
    NSString *nsString = [[[ObjectiveCTest alloc] init] test];
    const char *cString = [nsString cStringUsingEncoding:NSString.defaultCStringEncoding];
    return env->NewStringUTF(cString);
}

@implementation ObjectiveCTest

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
    return [NSString stringWithFormat:@"Hello NSString from %@", self];
}

- (void)dealloc
{
    NSLog(@"%@ %@", self, NSStringFromSelector(_cmd));
}

@end
