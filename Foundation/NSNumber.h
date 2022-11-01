#import "NSMiniRuntime.h"

enum _NSNumberType {
	NSNumberTypeChar,
	NSNumberTypeUnsignedChar,
	NSNumberTypeBool,
	NSNumberTypeShort,
	NSNumberTypeUnsignedShort,
	NSNumberTypeInt,
	NSNumberTypeUnsignedInt,
	NSNumberTypeLong,
	NSNumberTypeUnsignedLong,
	NSNumberTypeFloat,
	NSNumberTypeDouble
};

@interface NSNumber : NSObject
{
	enum _NSNumberType _type;
	union {
		char asChar;
		char asUnsignedChar;
		BOOL asBool;
		short asShort;
		unsigned short asUnsignedShort;
		int asInt;
		unsigned asUnsignedInt;
		long asLong;
		unsigned long asUnsignedLong;
		float asFloat;
		double asDouble;
	} _value;
}

-(id) initWithChar: (char)value;
-(id) initWithUnsignedChar: (unsigned char)value;
-(id) initWithBool: (BOOL)value;
-(id) initWithShort: (short)value;
-(id) initWithUnsignedShort: (unsigned short)value;
-(id) initWithInt: (int)value;
-(id) initWithUnsignedInt: (unsigned)value;
-(id) initWithLong: (long)value;
-(id) initWithUnsignedLong: (unsigned long)value;
-(id) initWithFloat: (float)value;
-(id) initWithDouble: (double)value;

+(id) numberWithChar: (char)value;
+(id) numberWithUnsignedChar: (unsigned char)value;
+(id) numberWithBool: (BOOL)value;
+(id) numberWithShort: (short)value;
+(id) numberWithUnsignedShort: (unsigned short)value;
+(id) numberWithInt: (int)value;
+(id) numberWithUnsignedInt: (unsigned)value;
+(id) numberWithLong: (long)value;
+(id) numberWithUnsignedLong: (unsigned long)value;
+(id) numberWithFloat: (float)value;
+(id) numberWithDouble: (double)value;

-(char) charValue;
-(unsigned char) unsignedCharValue;
-(BOOL) boolValue;
-(short) shortValue;
-(unsigned short) unsignedShortValue;
-(int) intValue;
-(unsigned) unsignedIntValue;
-(long) longValue;
-(unsigned long) unsignedLongValue;
-(float) floatValue;
-(double) doubleValue;

@end