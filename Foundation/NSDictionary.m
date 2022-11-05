#import "NSDictionary.h"
#import "NSString.h"
#import "NSEnumerator.h"
#include <Types.h>

@interface NSDictionaryEnumerator : NSEnumerator
{
	struct NSDictionaryImplIterator *_impl;
}

// private
-(id) initWithDictionaryImpl: (struct NSDictionaryImpl*)dict;

@end


@interface NSDictionaryKeyEnumerator : NSDictionaryEnumerator

-(id) nextObject;

@end


@interface NSDictionaryObjectEnumerator : NSDictionaryEnumerator

-(id) nextObject;

@end


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

-(NSEnumerator*) keyEnumerator {
	return [[[NSDictionaryKeyEnumerator alloc] initWithDictionaryImpl: _impl] autorelease];
}

-(NSEnumerator*) objectEnumerator {
	return [[[NSDictionaryObjectEnumerator alloc] initWithDictionaryImpl: _impl] autorelease];
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

@implementation NSDictionaryEnumerator

-(id) initWithDictionaryImpl: (struct NSDictionaryImpl*)dict {
	self = [super init];
	if (self) {
		_impl = NSDictionaryImplEnumeratorNew(dict);
	}
	return self;
}

-(void) dealloc {
	NSDictionaryImplEnumeratorFree(_impl);
	
	[super dealloc];
}

@end

@implementation NSDictionaryKeyEnumerator

-(id) nextObject {
	const char* keyString = NSDictionaryImplEnumeratorNextKey(_impl);
	NSString *result = nil;
	if (keyString) {
		result = [NSString stringWithCString: keyString];
	}
	return result;
}

@end

@implementation NSDictionaryObjectEnumerator

-(id) nextObject {
	return NSDictionaryImplEnumeratorNextObject(_impl);
}

@end
