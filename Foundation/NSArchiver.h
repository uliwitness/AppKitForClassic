#import "NSMiniRuntime.h"
#import "NSCoder.h"

@class NSMutableByteStream;
@class NSByteStream;
@class NSData;

@protocol NSCoding

-(id) initWithCoder: (NSCoder*)coder;
-(void) encodeWithCoder: (NSCoder*)coder;

@end

@interface NSArchiver : NSCoder
{
	NSMutableByteStream *_stream;
}

+(NSData *) archivedDataWithRootObject: (id)obj;

@end

@interface NSUnarchiver : NSCoder
{
	NSByteStream *_stream;
}

+(id) unarchiveObjectWithData: (NSData*)archivedData;

@end