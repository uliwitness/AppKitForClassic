#import "NSData.h"
#import "NSString.h"
#include <stdlib.h>
#include <stdio.h>
#include <Memory.h>

@implementation NSData

-(id) initWithBytes: (const void*)bytes length: (unsigned)length {
	self = [super init];
	if (self) {
		_bytes = malloc(length);
		BlockMoveData(bytes, _bytes, length);
		_length = length;
	}
	return self;
}

-(id) initWithData: (NSData*)original {
	return [self initWithBytes: [original bytes] length: [original length]];
}

-(id) initWithContentsOfFile: (NSString*)path {
	self = [super init];
	if (self) {
		FILE *file = fopen([path cString], "r");
		if (!file) {
			[self release];
			return nil;
		}
		fseek(file, 0, SEEK_END);
		_length = ftell(file);
		fseek(file, 0, SEEK_SET);
		_bytes = malloc(_length);
		fread(_bytes, 1, _length, file);
		fclose(file);
	}
	return self;
}

-(void) dealloc {
	free(_bytes);
	_bytes = NULL;
	_length = 0;
	
	[super dealloc];
}

-(unsigned) length {
	return _length;
}

-(const void*) bytes {
	return _bytes;
}

-(BOOL) writeToFile: (NSString*)path atomically: (BOOL)ignored {
	long writtenLength = 0;
	FILE *file = fopen([path cString], "w");
	if (!file) {
		return NO;
	}
	writtenLength = fwrite(_bytes, 1, _length, file);
	fclose(file);
	
	return (writtenLength == _length);
}

@end
