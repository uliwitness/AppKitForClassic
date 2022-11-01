#import "NSNumber.h"
#import "NSString.h"
#include <stdio.h>

@implementation NSNumber

-(id) initWithChar: (char)value {
	self = [super init];
	if (self) {
		_value.asChar = value;
		_type = NSNumberTypeChar;
	}
	
	return self;
}

-(id) initWithUnsignedChar: (unsigned char)value {
	self = [super init];
	if (self) {
		_value.asUnsignedChar = value;
		_type = NSNumberTypeUnsignedChar;
	}
	
	return self;
}

-(id) initWithBool: (BOOL)value {
	self = [super init];
	if (self) {
		_value.asBool = value;
		_type = NSNumberTypeBool;
	}
	
	return self;
}

-(id) initWithShort: (short)value {
	self = [super init];
	if (self) {
		_value.asShort = value;
		_type = NSNumberTypeShort;
	}
	
	return self;
}

-(id) initWithUnsignedShort: (unsigned short)value {
	self = [super init];
	if (self) {
		_value.asUnsignedShort = value;
		_type = NSNumberTypeUnsignedShort;
	}
	
	return self;
}

-(id) initWithInt: (int)value {
	self = [super init];
	if (self) {
		_value.asInt = value;
		_type = NSNumberTypeInt;
	}
	
	return self;
}

-(id) initWithUnsignedInt: (unsigned)value {
	self = [super init];
	if (self) {
		_value.asUnsignedInt = value;
		_type = NSNumberTypeUnsignedInt;
	}
	
	return self;
}

-(id) initWithLong: (long)value {
	self = [super init];
	if (self) {
		_value.asLong = value;
		_type = NSNumberTypeLong;
	}
	
	return self;
}

-(id) initWithUnsignedLong: (unsigned long)value {
	self = [super init];
	if (self) {
		_value.asUnsignedLong = value;
		_type = NSNumberTypeUnsignedLong;
	}
	
	return self;
}

-(id) initWithFloat: (float)value {
	self = [super init];
	if (self) {
		_value.asFloat = value;
		_type = NSNumberTypeFloat;
	}
	
	return self;
}

-(id) initWithDouble: (double)value {
	self = [super init];
	if (self) {
		_value.asDouble = value;
		_type = NSNumberTypeDouble;
	}
	
	return self;
}


+(id) numberWithChar: (char)value {
	return [[[self alloc] initWithChar: value] autorelease];
}

+(id) numberWithUnsignedChar: (unsigned char)value {
	return [[[self alloc] initWithUnsignedChar: value] autorelease];
}

+(id) numberWithBool: (BOOL)value {
	return [[[self alloc] initWithBool: value] autorelease];
}

+(id) numberWithShort: (short)value {
	return [[[self alloc] initWithShort: value] autorelease];
}

+(id) numberWithUnsignedShort: (unsigned short)value {
	return [[[self alloc] initWithUnsignedShort: value] autorelease];
}

+(id) numberWithInt: (int)value {
	return [[[self alloc] initWithInt: value] autorelease];
}

+(id) numberWithUnsignedInt: (unsigned)value {
	return [[[self alloc] initWithUnsignedInt: value] autorelease];
}

+(id) numberWithLong: (long)value {
	return [[[self alloc] initWithLong: value] autorelease];
}

+(id) numberWithUnsignedLong: (unsigned long)value {
	return [[[self alloc] initWithUnsignedLong: value] autorelease];
}

+(id) numberWithFloat: (float)value {
	return [[[self alloc] initWithFloat: value] autorelease];
}

+(id) numberWithDouble: (double)value {
	return [[[self alloc] initWithDouble: value] autorelease];
}


-(char) charValue {
	char result = 0;
	switch (_type) {
		case NSNumberTypeChar:
			result = _value.asChar;
			break;
			
		case NSNumberTypeUnsignedChar:
			result = _value.asUnsignedChar;
			break;
			
		case NSNumberTypeBool:
			result = _value.asBool;
			break;
			
		case NSNumberTypeShort:
			result = _value.asShort;
			break;
			
		case NSNumberTypeUnsignedShort:
			result = _value.asUnsignedShort;
			break;
		
		case NSNumberTypeInt:
			result = _value.asInt;
			break;
			
		case NSNumberTypeUnsignedInt:
			result = _value.asUnsignedInt;
			break;
		
		case NSNumberTypeLong:
			result = _value.asLong;
			break;
			
		case NSNumberTypeUnsignedLong:
			result = _value.asUnsignedLong;
			break;
		
		case NSNumberTypeFloat:
			result = _value.asFloat;
			break;
			
		case NSNumberTypeDouble:
			result = _value.asDouble;
			break;
	}
	return result;
}

-(unsigned char) unsignedCharValue {
	unsigned char result = 0;
	switch (_type) {
		case NSNumberTypeChar:
			result = _value.asChar;
			break;
			
		case NSNumberTypeUnsignedChar:
			result = _value.asUnsignedChar;
			break;
			
		case NSNumberTypeBool:
			result = _value.asBool;
			break;
			
		case NSNumberTypeShort:
			result = _value.asShort;
			break;
			
		case NSNumberTypeUnsignedShort:
			result = _value.asUnsignedShort;
			break;
		
		case NSNumberTypeInt:
			result = _value.asInt;
			break;
			
		case NSNumberTypeUnsignedInt:
			result = _value.asUnsignedInt;
			break;
		
		case NSNumberTypeLong:
			result = _value.asLong;
			break;
			
		case NSNumberTypeUnsignedLong:
			result = _value.asUnsignedLong;
			break;
		
		case NSNumberTypeFloat:
			result = _value.asFloat;
			break;
			
		case NSNumberTypeDouble:
			result = _value.asDouble;
			break;
	}
	return result;
}

-(BOOL) boolValue {
	BOOL result = 0;
	switch (_type) {
		case NSNumberTypeChar:
			result = _value.asChar;
			break;
			
		case NSNumberTypeUnsignedChar:
			result = _value.asUnsignedChar;
			break;
			
		case NSNumberTypeBool:
			result = _value.asBool;
			break;
			
		case NSNumberTypeShort:
			result = _value.asShort;
			break;
			
		case NSNumberTypeUnsignedShort:
			result = _value.asUnsignedShort;
			break;
		
		case NSNumberTypeInt:
			result = _value.asInt;
			break;
			
		case NSNumberTypeUnsignedInt:
			result = _value.asUnsignedInt;
			break;
		
		case NSNumberTypeLong:
			result = _value.asLong;
			break;
			
		case NSNumberTypeUnsignedLong:
			result = _value.asUnsignedLong;
			break;
		
		case NSNumberTypeFloat:
			result = _value.asFloat;
			break;
			
		case NSNumberTypeDouble:
			result = _value.asDouble;
			break;
	}
	return result;
}

-(short) shortValue {
	short result = 0;
	switch (_type) {
		case NSNumberTypeChar:
			result = _value.asChar;
			break;
			
		case NSNumberTypeUnsignedChar:
			result = _value.asUnsignedChar;
			break;
			
		case NSNumberTypeBool:
			result = _value.asBool;
			break;
			
		case NSNumberTypeShort:
			result = _value.asShort;
			break;
			
		case NSNumberTypeUnsignedShort:
			result = _value.asUnsignedShort;
			break;
		
		case NSNumberTypeInt:
			result = _value.asInt;
			break;
			
		case NSNumberTypeUnsignedInt:
			result = _value.asUnsignedInt;
			break;
		
		case NSNumberTypeLong:
			result = _value.asLong;
			break;
			
		case NSNumberTypeUnsignedLong:
			result = _value.asUnsignedLong;
			break;
		
		case NSNumberTypeFloat:
			result = _value.asFloat;
			break;
			
		case NSNumberTypeDouble:
			result = _value.asDouble;
			break;
	}
	return result;
}

-(unsigned short) unsignedShortValue {
	unsigned short result = 0;
	switch (_type) {
		case NSNumberTypeChar:
			result = _value.asChar;
			break;
			
		case NSNumberTypeUnsignedChar:
			result = _value.asUnsignedChar;
			break;
			
		case NSNumberTypeBool:
			result = _value.asBool;
			break;
			
		case NSNumberTypeShort:
			result = _value.asShort;
			break;
			
		case NSNumberTypeUnsignedShort:
			result = _value.asUnsignedShort;
			break;
		
		case NSNumberTypeInt:
			result = _value.asInt;
			break;
			
		case NSNumberTypeUnsignedInt:
			result = _value.asUnsignedInt;
			break;
		
		case NSNumberTypeLong:
			result = _value.asLong;
			break;
			
		case NSNumberTypeUnsignedLong:
			result = _value.asUnsignedLong;
			break;
		
		case NSNumberTypeFloat:
			result = _value.asFloat;
			break;
			
		case NSNumberTypeDouble:
			result = _value.asDouble;
			break;
	}
	return result;
}

-(int) intValue {
	int result = 0;
	switch (_type) {
		case NSNumberTypeChar:
			result = _value.asChar;
			break;
			
		case NSNumberTypeUnsignedChar:
			result = _value.asUnsignedChar;
			break;
			
		case NSNumberTypeBool:
			result = _value.asBool;
			break;
			
		case NSNumberTypeShort:
			result = _value.asShort;
			break;
			
		case NSNumberTypeUnsignedShort:
			result = _value.asUnsignedShort;
			break;
		
		case NSNumberTypeInt:
			result = _value.asInt;
			break;
			
		case NSNumberTypeUnsignedInt:
			result = _value.asUnsignedInt;
			break;
		
		case NSNumberTypeLong:
			result = _value.asLong;
			break;
			
		case NSNumberTypeUnsignedLong:
			result = _value.asUnsignedLong;
			break;
		
		case NSNumberTypeFloat:
			result = _value.asFloat;
			break;
			
		case NSNumberTypeDouble:
			result = _value.asDouble;
			break;
	}
	return result;
}

-(unsigned) unsignedIntValue {
	unsigned result = 0;
	switch (_type) {
		case NSNumberTypeChar:
			result = _value.asChar;
			break;
			
		case NSNumberTypeUnsignedChar:
			result = _value.asUnsignedChar;
			break;
			
		case NSNumberTypeBool:
			result = _value.asBool;
			break;
			
		case NSNumberTypeShort:
			result = _value.asShort;
			break;
			
		case NSNumberTypeUnsignedShort:
			result = _value.asUnsignedShort;
			break;
		
		case NSNumberTypeInt:
			result = _value.asInt;
			break;
			
		case NSNumberTypeUnsignedInt:
			result = _value.asUnsignedInt;
			break;
		
		case NSNumberTypeLong:
			result = _value.asLong;
			break;
			
		case NSNumberTypeUnsignedLong:
			result = _value.asUnsignedLong;
			break;
		
		case NSNumberTypeFloat:
			result = _value.asFloat;
			break;
			
		case NSNumberTypeDouble:
			result = _value.asDouble;
			break;
	}
	return result;
}

-(long) longValue {
	long result = 0;
	switch (_type) {
		case NSNumberTypeChar:
			result = _value.asChar;
			break;
			
		case NSNumberTypeUnsignedChar:
			result = _value.asUnsignedChar;
			break;
			
		case NSNumberTypeBool:
			result = _value.asBool;
			break;
			
		case NSNumberTypeShort:
			result = _value.asShort;
			break;
			
		case NSNumberTypeUnsignedShort:
			result = _value.asUnsignedShort;
			break;
		
		case NSNumberTypeInt:
			result = _value.asInt;
			break;
			
		case NSNumberTypeUnsignedInt:
			result = _value.asUnsignedInt;
			break;
		
		case NSNumberTypeLong:
			result = _value.asLong;
			break;
			
		case NSNumberTypeUnsignedLong:
			result = _value.asUnsignedLong;
			break;
		
		case NSNumberTypeFloat:
			result = _value.asFloat;
			break;
			
		case NSNumberTypeDouble:
			result = _value.asDouble;
			break;
	}
	return result;
}

-(unsigned long) unsignedLongValue {
	unsigned long result = 0;
	switch (_type) {
		case NSNumberTypeChar:
			result = _value.asChar;
			break;
			
		case NSNumberTypeUnsignedChar:
			result = _value.asUnsignedChar;
			break;
			
		case NSNumberTypeBool:
			result = _value.asBool;
			break;
			
		case NSNumberTypeShort:
			result = _value.asShort;
			break;
			
		case NSNumberTypeUnsignedShort:
			result = _value.asUnsignedShort;
			break;
		
		case NSNumberTypeInt:
			result = _value.asInt;
			break;
			
		case NSNumberTypeUnsignedInt:
			result = _value.asUnsignedInt;
			break;
		
		case NSNumberTypeLong:
			result = _value.asLong;
			break;
			
		case NSNumberTypeUnsignedLong:
			result = _value.asUnsignedLong;
			break;
		
		case NSNumberTypeFloat:
			result = _value.asFloat;
			break;
			
		case NSNumberTypeDouble:
			result = _value.asDouble;
			break;
	}
	return result;
}

-(float) floatValue {
	float result = 0;
	switch (_type) {
		case NSNumberTypeChar:
			result = _value.asChar;
			break;
			
		case NSNumberTypeUnsignedChar:
			result = _value.asUnsignedChar;
			break;
			
		case NSNumberTypeBool:
			result = _value.asBool;
			break;
			
		case NSNumberTypeShort:
			result = _value.asShort;
			break;
			
		case NSNumberTypeUnsignedShort:
			result = _value.asUnsignedShort;
			break;
		
		case NSNumberTypeInt:
			result = _value.asInt;
			break;
			
		case NSNumberTypeUnsignedInt:
			result = _value.asUnsignedInt;
			break;
		
		case NSNumberTypeLong:
			result = _value.asLong;
			break;
			
		case NSNumberTypeUnsignedLong:
			result = _value.asUnsignedLong;
			break;
		
		case NSNumberTypeFloat:
			result = _value.asFloat;
			break;
			
		case NSNumberTypeDouble:
			result = _value.asDouble;
			break;
	}
	return result;
}

-(double) doubleValue {
	double result = 0;
	switch (_type) {
		case NSNumberTypeChar:
			result = _value.asChar;
			break;
			
		case NSNumberTypeUnsignedChar:
			result = _value.asUnsignedChar;
			break;
			
		case NSNumberTypeBool:
			result = _value.asBool;
			break;
			
		case NSNumberTypeShort:
			result = _value.asShort;
			break;
			
		case NSNumberTypeUnsignedShort:
			result = _value.asUnsignedShort;
			break;
		
		case NSNumberTypeInt:
			result = _value.asInt;
			break;
			
		case NSNumberTypeUnsignedInt:
			result = _value.asUnsignedInt;
			break;
		
		case NSNumberTypeLong:
			result = _value.asLong;
			break;
			
		case NSNumberTypeUnsignedLong:
			result = _value.asUnsignedLong;
			break;
		
		case NSNumberTypeFloat:
			result = _value.asFloat;
			break;
			
		case NSNumberTypeDouble:
			result = _value.asDouble;
			break;
	}
	return result;
}

-(NSString*) description {
	char numStr[100];
	unsigned len = 0;
	switch (_type) {
		case NSNumberTypeChar:
			len = sprintf(numStr, "%d", _value.asChar);
			break;
			
		case NSNumberTypeUnsignedChar:
			len = sprintf(numStr, "%u", _value.asUnsignedChar);
			break;
			
		case NSNumberTypeBool:
			len = sprintf(numStr, "%s", _value.asBool ? "YES" : "NO");
			break;
			
		case NSNumberTypeShort:
			len = sprintf(numStr, "%d", _value.asShort);
			break;
			
		case NSNumberTypeUnsignedShort:
			len = sprintf(numStr, "%u", _value.asUnsignedShort);
			break;
		
		case NSNumberTypeInt:
			len = sprintf(numStr, "%d", _value.asInt);
			break;
			
		case NSNumberTypeUnsignedInt:
			len = sprintf(numStr, "%u", _value.asUnsignedInt);
			break;
		
		case NSNumberTypeLong:
			len = sprintf(numStr, "%ld", _value.asLong);
			break;
			
		case NSNumberTypeUnsignedLong:
			len = sprintf(numStr, "%lu", _value.asUnsignedLong);
			break;
		
		case NSNumberTypeFloat:
			len = sprintf(numStr, "%f", _value.asFloat);
			break;
			
		case NSNumberTypeDouble:
			len = sprintf(numStr, "%f", _value.asDouble);
			break;
	}
	return [NSString stringWithCharacters: numStr length: len];
}

@end