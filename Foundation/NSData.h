#import "NSMiniRuntime.h"

@interface NSData : NSObject
{
	void* _bytes;
	unsigned _length;
}

-(id) initWithBytes: (const void*)bytes length: (unsigned)length;
-(id) initWithData: (NSData*)original;
-(id) initWithContentsOfFile: (NSString*)path;

-(unsigned) length;
-(const void*) bytes;

-(BOOL) writeToFile: (NSString*)path atomically: (BOOL)ignored;

@end
