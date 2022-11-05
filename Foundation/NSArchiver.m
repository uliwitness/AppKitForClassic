#import "NSArchiver.h"
#import "NSData.h"
#import "NSByteStream.h"
#include <Memory.h>
#include <string.h>

@implementation NSArchiver

+(NSData *) archivedDataWithRootObject: (id)obj {
	NSArchiver *archiver = [[NSArchiver alloc] init];
	Handle handle = NULL;
	NSData *data = nil;
	[archiver encodeObject: obj];
	handle = [archiver->_stream macHandle];
	HLock(handle);
	data = [[[NSData alloc] initWithBytes: *handle length: GetHandleSize(handle)] autorelease];
	HUnlock(handle);
	[archiver release];
	return data;
}

-(id) init {
	self = [super init];
	if (self) {
		_stream = [[NSMutableByteStream alloc] init];
	}
	return self;
}

-(void) dealloc {
	[_stream release];
	_stream = nil;

	[super dealloc];
}

-(void) encodeObject: (id)obj {
	const char *className = [obj class]->name;
	[_stream writeBytes: className count: strlen(className) +1];
	[obj encodeWithCoder: self];
}

-(void) encodeBool: (BOOL)num {
	[_stream writeUInt8: num];
}

-(void) encodeInt: (int)num {
	[_stream writeSInt16: num];
}

-(void) encodeInt32: (SInt32)num {
	[_stream writeSInt32: num];
}

-(void) encodeFloat: (float)num {
	[_stream writeFloat: num];
}

-(void) encodeDouble: (double)num {
	[_stream writeDouble: num];
}

-(void) encodeBytes: (const void *)bytes length: (unsigned)len {
	[_stream writeBytes: bytes count: len];
}

@end

@implementation NSUnarchiver

+(id) unarchiveObjectWithData: (NSData*)archivedData {
	NSUnarchiver *unarchiver = nil;
	id obj = nil;
	Handle handle = NewHandle([archivedData length]);
	BlockMoveData([archivedData bytes], *handle, [archivedData length]);
	unarchiver = [[NSUnarchiver alloc] initWithHandle: handle];
	obj = [unarchiver decodeObject];
	[unarchiver release];
	return obj;
}

-(id) initWithHandle: (Handle)handle {
	self = [super init];
	if (self) {
		_stream = [[NSByteStream alloc] initWithHandle: handle];
	}
	return self;
}

-(void) dealloc {
	[_stream release];
	_stream = nil;

	[super dealloc];
}

-(id) decodeObject {
	id result = nil;
	Class theClass = NULL;
	char className[100] = {0};
	[_stream readCStr: className length: sizeof(className)];
	theClass = objc_getClass(className);
	result = [[[theClass alloc] initWithCoder: self] autorelease];
	return result;
}

-(BOOL) decodeBool {
	return [_stream readUInt8];
}

-(int) decodeInt {
	return [_stream readSInt16];
}

-(int) decodeInt32 {
	return [_stream readSInt32];
}

-(float) decodeFloat {
	return [_stream readFloat];
}

-(double) decodeDouble {
	return [_stream readDouble];
}

-(void) decodeBytes: (void*)destBuf length: (unsigned)len {
	[_stream readBytes: destBuf count: len];
}

@end
