#import "NSDictionary.h"
#import "NSString.h"
#include <Types.h>

@implementation NSDictionary

-(id) init {
	return [self initWithImpl: NULL];
}

-(id) initWithImpl: (struct NSDictionaryImpl*)impl {
	self = [super init];
	if (self) {
		if (impl) {
			_impl = NSDictionaryImplNewCopy(impl);
		} else {
			_impl = NSDictionaryImplNew();
		}
	}
	return self;
}

-(void) dealloc {
	if (_impl) {
		NSDictionaryImplFree(_impl);
		_impl = NULL;
	}
}

-(id) objectForKey: (NSString*)key {
	return NSDictionaryImplGetObjectForKey(_impl, [key cString]);
}

-(id) copy {
	return [[NSDictionary alloc] initWithImpl: _impl]; 
}

-(id) mutableCopy {
	return [[NSMutableDictionary alloc] initWithImpl: _impl]; 
}

@end

@implementation NSMutableDictionary

-(void) setObject: (id)obj forKey: (NSString*)key {
	NSDictionaryImplSetObjectForKey(_impl, obj, [key cString]);
}

-(void) removeObjectForKey: (NSString*)key {
	NSDictionaryImplRemoveObjectForKey(_impl, [key cString]);
}

@end
