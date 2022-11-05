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

-(id) initWithHandle: (Handle)handle;
-(id) initWithUnownedHandle: (Handle)inBuffer;
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

// Returns 0 if there's not enough data and moves mOffset to the end.
-(float) readFloat;
// Returns 0 if there's not enough data and moves mOffset to the end.
-(double) readDouble;

// Returns false if there's not enough data and moves mOffset to the end.
-(Boolean) readBoolean;

// Sets outString to an empty string and returns NO and moves mOffset to the end if there isn't enough data.
-(BOOL) readStr255: (Str255)outString;
// Sets outString to an empty string and returns NO and moves mOffset to the end if there isn't enough data.
-(BOOL) readCStr: (char*)outString length: (unsigned)maxLength;
// Sets outRect to an empty rect and returns NO and moves mOffset to the end if there isn't enough data.
-(BOOL) readRect: (Rect*)outRect;

// Returns YES if mOffset is now aligned on 'multiple', NO and moves mOffset to the end if there was not enough data.
-(BOOL) alignOn: (Size)multiple;
// Returns YES if offset is now odd, NO and moves mOffset to the end if there's not enough data.
-(BOOL) misalign;
// Returns YES if there was enough data to skip still in the buffer, NO and moves mOffset to the end if there was not enough data.
-(BOOL) skip: (Size)skip;

-(Size) bytesLeft;

-(Handle) macHandle;

@end

@interface NSMutableByteStream : NSByteStream

-(id) initWithUnownedResource: (Handle)inBuffer;

-(void) writeBytes: (const void*)buffer count: (Size)count;

-(void) writeUInt8: (UInt8)num;

-(void) writeSInt8: (SInt8)num;

-(void) writeUInt16: (UInt16)num;

-(void) writeSInt16: (SInt16)num;

-(void) writeUInt32: (UInt32)num;

-(void) writeSInt32: (SInt32)num;

-(void) writeFloat: (float)num;

-(void) writeDouble: (double)num;

-(void) writeBoolean: (Boolean)num;

-(void) writeStr255: (Str255)str;

-(void) writeRect: (Rect)box;

@end
