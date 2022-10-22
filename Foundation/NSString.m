#import "NSString.h"
#import "NSStringPrivate.h"
#import "NSAutoreleasePool.h"
#include <string.h>
#include <memory.h>
#include <stdlib.h>
#include <OSUtils.h>

// Dummy class used for creating subclass instances when you call
// alloc/initXXX on an object on NSString. Note these are *class*
// methods. We return the class object of NSStringAllocProxy from
// alloc, and people think it's an NSString, and duck typing takes
// care that they can call init methods on it.
@interface NSStringAllocProxy : NSObject

+(id) initWithCString: (const char*)text;
+(id) initWithCharacters: (const char*)text length: (unsigned)len;
+(id) initWithStr255: (Str255)text;

@end


@implementation NSString

+alloc
{
	// Not a subclass calling super?
	if(self == [NSString class]) {
		return [NSStringAllocProxy class];
	} else { // Subclass calling super, let it allocate the subclass.
		return [super alloc];
	}
}

- (unsigned) length
{
	return 0;
}

- (const char *)cString
{
	return "";
}

// These will never be called, as we redirect these to NSStringAllocProxy,
// but this shuts up the compiler:

-(id) initWithCString: (const char*)text {
	DebugStr("\pShould never be called!");
	return nil;
}

-(id) initWithCharacters: (const char*)text length: (unsigned)len {
	DebugStr("\pShould never be called!");
	return nil;
}

-(id) initWithStr255: (Str255)text {
	DebugStr("\pShould never be called!");
	return nil;
}

@end

// Note: The MWObjC compiler assumes the NSConstantString layout is isa, bytes pointer, length.
//	If you add the Refcount to MWObject, this will break. That's why MWObject still exists, and
//	NSObject subclasses that.
@implementation NSConstantString

- (unsigned) length
{
	return _numBytes;
}

- (const char *)cString
{
	return _bytes;
}

@end

@implementation NSRefCountedString

+(id) alloc
{
	NSRefCountedString *newobj = [super alloc];
	newobj->_referenceCount = 1;
	return newobj;
}

-(id)retain
{
	++self->_referenceCount; // TODO: Make thread-safe.
	return self;
}

-(void)release
{
	if( (--self->_referenceCount) == 0 ) {
		[self dealloc];
	} 
}

-(id) autorelease
{
	[gCurrentPool addObject: (NSObject *)self];
	return self;
}

@end


@implementation NSCString

-(id) initWithCString: (const char*)text
{
	self = [super init];
	if( self ) {
		_numBytes = strlen(text);
		_bytes = malloc( _numBytes + 1 );
		memcpy( _bytes, text, _numBytes + 1 );
	}
	return self;
}

-(id) initWithCharacters: (const char*)text length: (unsigned)len
{
	self = [super init];
	if( self ) {
		_numBytes = len;
		_bytes = malloc( len + 1 );
		memcpy( _bytes, text, len );
		_bytes[len] = 0;
	}
	return self;
}

-(void) dealloc
{
	free(_bytes);
	_bytes = NULL;
	
	[super dealloc];
}

-(const char*) cString
{
	return _bytes;
}

- (unsigned) length {
	return _numBytes;
}

@end

@implementation NSPString

-(id) initWithStr255: (Str255)text
{
	self = [super init];
	if( self ) {
		memcpy(_text, text, text[0] + 1);
		_text[_text[0] + 1] = 0;
	}
	return self;
}

-(const char*) cString
{
	return _text + 1;
}

- (unsigned) length {
	return _text[0];
}

@end

@implementation NSStringAllocProxy

+(id) init
{
	return @"";
}

+(id) initWithCString: (const char*)text
{
	return [[NSCString alloc] initWithCString: text];
}

+(id) initWithCharacters: (const char*)text length: (unsigned)len
{
	return [[NSCString alloc] initWithCharacters: text length: len];
}

+(id) initWithStr255: (Str255)text
{
	return [[NSPString alloc] initWithStr255: text];
}

@end
