#import "ObjectiveCTest.h"

#include <jni.h>

extern "C" JNIEXPORT jstring JNICALL
Java_com_example_helloobjectivec_MainActivity_stringFromObjectiveC(
        JNIEnv *env,
        jobject /* this */) {
    NSString *nsString = [[[ObjectiveCTest alloc] init] test];
    const char *cString = [nsString cStringUsingEncoding:NSString.defaultCStringEncoding];
    return env->NewStringUTF(cString);
}


@implementation ObjectiveCTest

- (NSString *)test
{
    return [NSString stringWithFormat:@"Hello NSString from %@", self];
}

@end
