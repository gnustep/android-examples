#import "ObjC.h"

#include <jni.h>

#define APPNAME "helloobjectivec"

@implementation Test

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

- (void)throwException
{
    [NSException raise:NSInternalInconsistencyException format:@"Testing Objective-C exception from -[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
}

- (void)dealloc
{
    NSLog(@"%@ %@", self, NSStringFromSelector(_cmd));
}

@end

JNIEXPORT void JNICALL
Java_com_example_helloobjectivec_MainActivity_throwObjCException(JNIEnv *env, jobject this)
{
    [[[Test alloc] init] throwException];
}
