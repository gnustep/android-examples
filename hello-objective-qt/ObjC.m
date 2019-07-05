#include "ObjC.h"

#import <Foundation/Foundation.h>

@interface Test : NSObject
- (void)test;
@end

@implementation Test

- (void)test
{
	NSLog(@"Test Objective C");
}

@end

void testObjC()
{
	[[Test new] test];
}
