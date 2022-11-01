#import "NSMiniRuntime.h"
#import <Types.h>

enum {
	NSByteStreamOwnsBuffer = (1 << 0),
	NSByteStreamIsResourceBuffer = (1 << 1)
};
typedef UInt16 NSByteStreamFlags;


@interface NSByteStream : NSObject
{
	Handle mBuffer;
	Size mOffset;
	NSByteStreamFlags mFlags;
}

-(id) initWithResource: (Handle)inBuffer;

// Returns NO if there's not enough data and moves mOffset to the end.
-(BOOL) readBytes: (void*)buffer count: (Size)count;

// Returns 0 if there's not enough data and moves mOffset to the end.
-(UInt8) readUInt8;
// Returns 0 if there's not enough data and moves mOffset to the end.
-(SInt8) readSInt8;

// Returns 0 if there's not enough data and moves mOffset to the end.
-(SInt16) readSInt16;
// Returns 0 if there's not enough data and moves mOffset to the end.
-(UInt16) readUInt16;

// Returns 0 if there's not enough data and moves mOffset to the end.
-(SInt32) readSInt32;
// Returns 0 if there's not enough data and moves mOffset to the end.
-(UInt32) readUInt32;

// Returns false if there's not enough data and moves mOffset to the end.
-(Boolean) readBoolean;

// Sets outString to an empty string and returns NO and moves mOffset to the end if there isn't enough data.
-(BOOL) readStr255: (Str255)outString;
// Sets outRect to an empty rect and returns NO and moves mOffset to the end if there isn't enough data.
-(BOOL) readRect: (Rect*)outRect;

// Returns YES if mOffset is now aligned on 'multiple', NO and moves mOffset to the end if there was not enough data.
-(BOOL) alignOn: (Size)multiple;
// Returns YES if offset is now odd, NO and moves mOffset to the end if there's not enough data.
-(BOOL) misalign;
// Returns YES if there was enough data to skip still in the buffer, NO and moves mOffset to the end if there was not enough data.
-(BOOL) skip: (Size)skip;

-(Size) bytesLeft;

@end