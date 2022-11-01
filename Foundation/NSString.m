#import "NSString.h"
#import "NSStringPrivate.h"
#import "NSAutoreleasePool.h"
#include <string.h>
#include <stdio.h>
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
+(id) initWithFormat: (NSString*)fmtObj, ...;
+(id) initWithFormat: (NSString*)fmtObj arguments: (va_list)varargs;

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

+(id) stringWithCString: (const char*)text {
	return [[[self alloc] initWithCString: text] autorelease];
}

+(id) stringWithCharacters: (const char*)text length: (unsigned)len {
	return [[[self alloc] initWithCharacters: text length: len] autorelease];
}

+(id) stringWithStr255: (Str255)text {
	return [[[self alloc] initWithStr255: text] autorelease];
}

+(id) stringWithFormat: (NSString*)fmtObj, ... {
	id result = nil;
	va_list ap;
	va_start(ap, fmtObj);
	result = [[[self alloc] initWithFormat: fmtObj arguments: ap] autorelease];
	va_end(ap);
	return result;
}

- (unsigned) length
{
	return 0;
}

- (const char *)cString
{
	return "";
}

-(NSString*) description {
	return self;
}

- (void) getStr255: (Str255)outString {
	unsigned len = [self length];
	if (len > 255) len = 255;
	outString[0] = len;
	BlockMoveData([self cString], outString + 1, len);
}


-(BOOL) isEqualToString: (NSString*)str {
	return strcmp([self cString], [str cString]) == 0;
}

- (NSRange) rangeOfString: (NSString*)pattern {
	const char* subject = [self cString];
	const char* found = strstr(subject, [pattern cString]);
	if (found == NULL) {
		return NSMakeRange(NSNotFound, 0);
	}
	return NSMakeRange(found -subject, [pattern length]);
}

- (NSString*) substringWithRange: (NSRange)range {
	const char* subject = NULL;
	if (NSMaxRange(range) > [self length]) {
		return nil;
	}
	subject = [self cString];
	return [[[NSString alloc] initWithCharacters: subject +range.location length: range.length] autorelease];
}

- (NSString*) substringFromIndex: (int)startIndex {
	const char* subject = NULL;
	if (startIndex < 0 || startIndex > [self length]) {
		return nil;
	}
	subject = [self cString];
	return [[[NSString alloc] initWithCharacters: subject +startIndex length: [self length] -startIndex] autorelease];
}

- (NSString*) substringToIndex: (int)length {
	const char* subject = NULL;
	if (length < 0 || length > [self length]) {
		return nil;
	}
	subject = [self cString];
	return [[[NSString alloc] initWithCharacters: subject length: length] autorelease];
}

-(id) copy {
	return [self retain];
}

-(id) mutableCopy {
	return [[NSMutableString alloc] initWithCharacters: [self cString] length: [self length]];
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

-(id) initWithFormat: (NSString*)fmtObj arguments: (va_list)ap {
	DebugStr("\pShould never be called!");
	return nil;
}

-(id) initWithFormat: (NSString*)fmtObj, ... {
	DebugStr("\pShould never be called!");
	return nil;
}

@end

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

- (void) getStr255: (Str255)outString {
	BlockMoveData(_text, outString, _text[0] + 1);
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

+(id) initWithFormat: (NSString*)fmtObj, ... {
	id result = nil;
	va_list ap;
	va_start(ap, fmtObj);
	result = [self initWithFormat: fmtObj arguments: ap];
	va_end(ap);
	return result;
}

+(id) initWithFormat: (NSString*)fmtObj arguments: (va_list)varargs {
	NSMutableString *result = [[NSMutableString alloc] init];
	[result appendFormat: fmtObj arguments: varargs];
	return result;
}

@end


@implementation NSMutableString

-(id) init
{
	char dummy = 0;
	return [self initWithCharacters: &dummy length: 0];
}

-(id) initWithCString: (const char*)text
{
	return [self initWithCharacters: text length: strlen(text)];
}

-(id) initWithCharacters: (const char*)text length: (unsigned)len
{
	self = [super init];
	if (self) {
		_length = len;
		_cString = malloc(len + 1);
		_cString[len] = 0;
	}
	return self;
}

-(id) initWithStr255: (Str255)text
{
	return [self initWithCharacters: (char*) text + 1 length: text[0]];
}

-(id) initWithFormat: (NSString*)fmtObj, ... {
	id result = nil;
	va_list ap;
	va_start(ap, fmtObj);
	result = [self initWithFormat: fmtObj arguments: ap];
	va_end(ap);
	return result;
}

-(id) initWithFormat: (NSString*)fmtObj arguments: (va_list)varargs {
	NSMutableString *result = [[NSMutableString alloc] init];
	[result appendFormat: fmtObj arguments: varargs];
	return result;
}

-(unsigned) length {
	return _length;
}

-(const char*) cString {
	return _cString;
}

-(void) replaceCharactersInRange: (NSRange)range withString: (NSString*)str {
	[self replaceCharactersInRange: range withCharacters: [str cString] length: [str length]];
}

-(void) appendString: (NSString*)strObj {
	[self replaceCharactersInRange: NSMakeRange(_length, 0) withString: strObj];
}

-(void) insertString: (NSString*)strObj atIndex: (unsigned)destIdx {
	[self replaceCharactersInRange: NSMakeRange(destIdx, 0) withString: strObj];
}

-(void) deleteCharactersInRange: (NSRange)delRange {
	[self replaceCharactersInRange: NSMakeRange(_length, 0) withString: @""];
}

-(void) setString: (NSString*)strObj {
	[self replaceCharactersInRange: NSMakeRange(0, _length) withString: strObj];
}

-(void) appendFormat: (NSString*)fmtObj, ... {
	va_list ap;
	va_start(ap, fmtObj);
	[self appendFormat: fmtObj arguments: ap];
	va_end(ap);
}

-(void) appendFormat: (NSString*)fmtObj arguments: (va_list)ap {
	unsigned x = 0;
	const char* fmt = [fmtObj cString];
	
	for (x = 0; fmt[x] != 0;) {
		
		if (fmt[x] == '%') {
			++x;
			switch (fmt[x]) {
				case '@': {
					id obj = nil;
					++x;
					obj = va_arg(ap, id);
					if (obj == nil) {
						[self replaceCharactersInRange: NSMakeRange(_length, 0) withCharacters: "(null)" length: 6];
					} else if ([obj respondsToSelector: @selector(description)]) {
						[self appendString: [obj description]];
					} else {
						const char* className = [obj class]->name;
						char openBracket = '<', closeBracket = '>';
						char hexAddress[100] = {0};
						unsigned addStrLen = 0;
						
						[self replaceCharactersInRange: NSMakeRange(_length, 0) withCharacters: className length: strlen(className)];
						[self replaceCharactersInRange: NSMakeRange(_length, 0) withCharacters: &openBracket length: 1];
						addStrLen = sprintf(hexAddress, "0x%08lx", (unsigned long)obj);
						[self replaceCharactersInRange: NSMakeRange(_length, 0) withCharacters: hexAddress length: addStrLen];
						[self replaceCharactersInRange: NSMakeRange(_length, 0) withCharacters: &closeBracket length: 1];
					}
					break;
				}
				case 'p': {
					char hexAddress[100] = {0};
					unsigned addStrLen = 0;
					void *ptr = NULL;
					++x;
					ptr = va_arg(ap, void*);
					addStrLen = sprintf(hexAddress, "0x%08lx", (unsigned long)ptr);
					[self replaceCharactersInRange: NSMakeRange(_length, 0) withCharacters: hexAddress length: addStrLen];
					break;
				}
				case 'c': {
					char num = 0;
					++x;
					num = va_arg(ap, char);
					[self replaceCharactersInRange: NSMakeRange(_length, 0) withCharacters: &num length: 1];
					break;
				}
				case 'd': {
					char numStr[100] = {0};
					unsigned numStrLen = 0;
					int num = 0;
					++x;
					num = va_arg(ap, int);
					numStrLen = sprintf(numStr, "%d", num);
					[self replaceCharactersInRange: NSMakeRange(_length, 0) withCharacters: numStr length: numStrLen];
					break;
				}
				case 'u': {
					char numStr[100] = {0};
					unsigned numStrLen = 0;
					unsigned num = 0;
					++x;
					num = va_arg(ap, unsigned);
					numStrLen = sprintf(numStr, "%u", num);
					[self replaceCharactersInRange: NSMakeRange(_length, 0) withCharacters: numStr length: numStrLen];
					break;
				}
				case 'x': {
					char numStr[100] = {0};
					unsigned numStrLen = 0;
					unsigned int num = 0;
					++x;
					num = va_arg(ap, int);
					numStrLen = sprintf(numStr, "%x", num);
					[self replaceCharactersInRange: NSMakeRange(_length, 0) withCharacters: numStr length: numStrLen];
					break;
				}
				case 'l': {
					char numStr[100] = {0};
					unsigned numStrLen = 0;
					++x;
					switch(fmt[x]) {
						case 'd': {
							long num = 0;
							++x;
							num = va_arg(ap, long);
							numStrLen = sprintf(numStr, "%ld", num);
							break;
						}
						case 'u': {
							unsigned long num = 0;
							++x;
							num = va_arg(ap, long);
							numStrLen = sprintf(numStr, "%lu", num);
							break;
						}
						case 'x': {
							unsigned long num = 0;
							++x;
							num = va_arg(ap, long);
							numStrLen = sprintf(numStr, "%lx", num);
							break;
						}
						case 0:
							return;
							break;
						default:
							[self replaceCharactersInRange: NSMakeRange(_length, 0) withCharacters: fmt + (x - 2) length: 3];
							++x;
							break;
					}
					[self replaceCharactersInRange: NSMakeRange(_length, 0) withCharacters: numStr length: numStrLen];
					break;
				}
				case 'f': {
					char numStr[100] = {0};
					unsigned numStrLen = 0;
					double num = 0;
					++x;
					num = va_arg(ap, double);
					numStrLen = sprintf(numStr, "%f", num);
					[self replaceCharactersInRange: NSMakeRange(_length, 0) withCharacters: numStr length: numStrLen];
					break;
				}
				case 's': {
					const char *str = NULL;
					++x;
					str = va_arg(ap, char *);
					[self replaceCharactersInRange: NSMakeRange(_length, 0) withCharacters: str length: strlen(str)];
					break;
				}
				case '%':
					[self replaceCharactersInRange: NSMakeRange(_length, 0) withCharacters: fmt + x length: 1];
					++x;
					break;
				case 0:
					return;
					break;
				default:
					[self replaceCharactersInRange: NSMakeRange(_length, 0) withCharacters: fmt + (x - 1) length: 2];
					++x;
					break;
			}
		} else {
			[self replaceCharactersInRange: NSMakeRange(_length, 0) withCharacters: fmt + x length: 1];
			++x;
		}
	}
}

-(id) copy {
	return [[NSString alloc] initWithCharacters: _cString length: _length];
}

-(id) mutableCopy {
	return [[NSMutableString alloc] initWithCharacters: _cString length: _length];
}

// Nonstandard, used by -replaceCharactersInRange:withString:
-(void) replaceCharactersInRange: (NSRange)range withCharacters: (const char*)bytes length: (unsigned)len {
	unsigned newLen = _length -range.length +len;
	
	// Enlarge string to fit more data, if needed:
	if (newLen > _length) {
		char *newBuf = realloc(_cString, newLen + 1); // +1 for 0 terminator.
		if (!newBuf) {
			return;
		}
		_cString = newBuf;
	}
	
	// Move any text after the insertion to new location (always at least the 0 terminator):
	BlockMoveData(_cString + NSMaxRange(range), _cString + range.location + len, _length - NSMaxRange(range) + 1); // +1 to also move 0 terminator.
	if (len > 0) {
		BlockMoveData(bytes, _cString + range.location, len); // Write new string into newly-opened location.
	}
	
	// Reduce size now that we've moved all data:
	if (newLen < _length) {
		char *newBuf = realloc(_cString, newLen + 1); // +1 for 0 terminator.
		if (!newBuf) { // Should never fail, we're making it smaller.
			return;
		}
		_cString = newBuf;
	}
	_length = newLen;
}


@end

