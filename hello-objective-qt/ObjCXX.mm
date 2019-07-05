#include "ObjC.h"

#import <Foundation/Foundation.h>

@interface TestCXX : NSObject
- (void)test;
@end

@implementation TestCXX

- (void)test
{
	NSLog(@"Test Objective C++");
}

@end

void testObjCXX()
{
	[[TestCXX new] test];
}
