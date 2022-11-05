#import "NSMiniRuntime.h"
#include <Types.h>

@interface NSCoder : NSObject

-(void) encodeObject: (id)obj;
-(id) decodeObject;

-(void) encodeBool: (BOOL)num;
-(BOOL) decodeBool;

-(void) encodeInt: (int)num;
-(int) decodeInt;

-(void) encodeInt32: (SInt32)num;
-(int) decodeInt32;

-(void) encodeFloat: (float)num;
-(float) decodeFloat;

-(void) encodeDouble: (double)num;
-(double) decodeDouble;

-(void) encodeBytes: (const void *)bytes length: (unsigned)len;
-(const void *) decodeBytesReturnedLength: (unsigned*)outLen;

@end
