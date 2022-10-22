#import "NSByteStream.h"
#include <string.h>
#include <Memory.h>
#include <Resources.h>


@implementation NSByteStream

-(id) initWithResource: (Handle)inBuffer {
	self = [super init];
	if (self) {
		mBuffer = inBuffer;
		mOffset = 0;
		mFlags = NSByteStreamIsResourceBuffer | NSByteStreamOwnsBuffer;
	}
	return self;
}

-(void) dealloc
{
	if ((mFlags & NSByteStreamIsResourceBuffer) == 0
		&& (mFlags & NSByteStreamOwnsBuffer) != 0) {
		DisposeHandle(mBuffer);
	} else if ((mFlags & NSByteStreamIsResourceBuffer) != 0
		&& (mFlags & NSByteStreamOwnsBuffer) != 0) {
		ReleaseResource(mBuffer);
	}
	
	[super dealloc];
}

-(BOOL) readBytes: (void*)buffer count: (Size)count {
	if (GetHandleSize(mBuffer) < (mOffset + count)) {
		memset(buffer, 0, count);
		mOffset = GetHandleSize(mBuffer);
		return NO;
	}
	
	BlockMoveData((*mBuffer) + mOffset, buffer, count);
	mOffset += count;
	
	return YES;
}

-(UInt8) readUInt8 {
	UInt8 result = 0;

	if (GetHandleSize(mBuffer) < (mOffset + sizeof(result))) {
		mOffset = GetHandleSize(mBuffer);
		return result;
	}
	
	BlockMoveData((*mBuffer) + mOffset, &result, sizeof(result));
	mOffset += sizeof(result);
	return result;
}

-(SInt8) readSInt8 {
	SInt8 result = 0;

	if (GetHandleSize(mBuffer) < (mOffset + sizeof(result))) {
		mOffset = GetHandleSize(mBuffer);
		return result;
	}
	
	BlockMoveData((*mBuffer) + mOffset, &result, sizeof(result));
	mOffset += sizeof(result);
	return result;
}

-(SInt16) readSInt16 {
	SInt16 result = 0;

	if (GetHandleSize(mBuffer) < (mOffset + sizeof(result))) {
		mOffset = GetHandleSize(mBuffer);
		return result;
	}
	
	BlockMoveData((*mBuffer) + mOffset, &result, sizeof(result));
	mOffset += sizeof(result);
	return result;
}

-(UInt16) readUInt16 {
	UInt16 result = 0;

	if (GetHandleSize(mBuffer) < (mOffset + sizeof(result))) {
		mOffset = GetHandleSize(mBuffer);
		return result;
	}
	
	BlockMoveData((*mBuffer) + mOffset, &result, sizeof(result));
	mOffset += sizeof(result);
	return result;
}

-(SInt32) readSInt32 {
	SInt32 result = 0;

	if (GetHandleSize(mBuffer) < (mOffset + sizeof(result))) {
		mOffset = GetHandleSize(mBuffer);
		return result;
	}
	
	BlockMoveData((*mBuffer) + mOffset, &result, sizeof(result));
	mOffset += sizeof(result);
	return result;
}

-(UInt32) readUInt32 {
	UInt32 result = 0;

	if (GetHandleSize(mBuffer) < (mOffset + sizeof(result))) {
		mOffset = GetHandleSize(mBuffer);
		return result;
	}
	
	BlockMoveData((*mBuffer) + mOffset, &result, sizeof(result));
	mOffset += sizeof(result);
	return result;
}

-(Boolean) readBoolean {
	UInt16 result = false;

	if (GetHandleSize(mBuffer) < (mOffset + sizeof(result))) {
		mOffset = GetHandleSize(mBuffer);
		return result;
	}
	
	BlockMoveData((*mBuffer) + mOffset, &result, sizeof(result));
	mOffset += sizeof(result);
	return result == 0x0100;
}

-(BOOL) readStr255: (Str255)outString {
	if (GetHandleSize(mBuffer) < (mOffset + 1)) {
		outString[0] = 0;
		outString[1] = 0;
		mOffset = GetHandleSize(mBuffer);
		return NO;
	}
	outString[0] = [self readUInt8];
	if (outString[0] < 255) {
		outString[outString[0]] = 0;
	}
	return [self readBytes: outString + 1 count: outString[0]];
}

-(BOOL) readRect: (Rect*)outRect {
	if (GetHandleSize(mBuffer) < (mOffset + sizeof(Rect))) {
		mOffset = GetHandleSize(mBuffer);
		memset(outRect, 0, sizeof(Rect));
		return NO;
	}
	
	BlockMoveData((*mBuffer) + mOffset, outRect, sizeof(Rect));
	mOffset += sizeof(Rect);
	return YES;
}

-(BOOL) alignOn: (Size)multiple {
	Size overhang = mOffset % multiple;
	Size skip = 0;
	if (overhang == 0) return YES;
	skip = multiple - overhang;
	if (GetHandleSize(mBuffer) < (mOffset + skip)) {
		mOffset = GetHandleSize(mBuffer);
		return NO;
	}
	mOffset += skip;
	return YES;
}

-(BOOL) misalign {
	Size overhang = mOffset % 2;
	if (overhang == 1) return YES;
	if (GetHandleSize(mBuffer) < (mOffset + 1)) {
		mOffset = GetHandleSize(mBuffer);
		return NO;
	}
	mOffset += 1;
	return YES;
}

-(BOOL) skip: (Size)skip {
	if (GetHandleSize(mBuffer) < (mOffset + skip)) {
		mOffset = GetHandleSize(mBuffer);
		return NO;
	}
	mOffset += skip;
	return YES;
}

-(Size) bytesLeft {
	return GetHandleSize(mBuffer) - mOffset;
}

@end