#import "NSMiniRuntime.h"
#include "NSDictionaryImpl.h"

@class NSEnumerator;

@interface NSDictionary : NSObject
{
	struct NSDictionaryImpl *_impl;
}

-(id) objectForKey: (NSString*)key;

-(id) copy;
-(id) mutableCopy;

-(NSEnumerator*) keyEnumerator;

// private
-(id) initWithImpl: (struct NSDictionaryImpl *)impl;

@end

@interface NSMutableDictionary : NSDictionary

-(void) setObject: (id)obj forKey: (NSString*)key;
-(void) removeObjectForKey: (NSString*)key;

@end
