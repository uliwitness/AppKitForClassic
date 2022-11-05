#import "NSByteStream.h"
#include <string.h>
#include <Memory.h>
#include <Resources.h>


@implementation NSByteStream

-(id) init {
	self = [super init];
	if (self) {
		mBuffer = NewHandle(0);
		mOffset = 0;
		mFlags = NSByteStreamOwnsBuffer;
	}
	return self;
}

-(id) initWithHandle: (Handle)handle {
	self = [super init];
	if (self) {
		mBuffer = handle;
		mOffset = 0;
		mFlags = NSByteStreamOwnsBuffer;
	}
	return self;
}

-(id) initWithUnownedHandle: (Handle)inBuffer {
	self = [super init];
	if (self) {
		mBuffer = inBuffer;
		mOffset = 0;
		mFlags = 0;
	}
	return self;
}

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

-(float) readFloat {
	float result = 0;

	if (GetHandleSize(mBuffer) < (mOffset + sizeof(result))) {
		mOffset = GetHandleSize(mBuffer);
		return result;
	}
	
	BlockMoveData((*mBuffer) + mOffset, &result, sizeof(result));
	mOffset += sizeof(result);
	return result;
}

-(double) readDouble {
	double result = 0;

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

-(BOOL) readCStr: (char*)outString length: (unsigned)maxLength {
	unsigned n = 0;
	char currCh = 0;
	if (maxLength < 1) {
		return NO;
	}
	while ((currCh = [self readSInt8])) {
		if (n >= maxLength) {
			outString[n - 1] = 0;
			return NO;
		}
		outString[n++] = currCh;
	}
	outString[n++] = 0;
	return YES;
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

-(Handle) macHandle {
	return mBuffer;
}

@end

@implementation NSMutableByteStream

-(id) initWithUnownedResource: (Handle)inBuffer {
	self = [super init];
	if (self) {
		mBuffer = inBuffer;
		mOffset = 0;
		mFlags = NSByteStreamIsResourceBuffer;
	}
	return self;
}

-(void) dealloc
{
	if ((mFlags & NSByteStreamIsResourceBuffer) != 0
		&& (mFlags & NSByteStreamOwnsBuffer) == 0) {
		ChangedResource(mBuffer);
	}
	
	[super dealloc];
}

-(void) writeBytes: (const void*)buffer count: (Size)count {
	Size bytesToAdd = -(GetHandleSize(mBuffer) - mOffset - count);
	if (bytesToAdd > 0) {
		SetHandleSize(mBuffer, GetHandleSize(mBuffer) + bytesToAdd);
	}
	BlockMoveData(buffer, *mBuffer + mOffset, count);
	mOffset += count;
}

-(void) writeUInt8: (UInt8)num {
	[self writeBytes: &num count: sizeof(num)];
}

-(void) writeSInt8: (SInt8)num {
	[self writeBytes: &num count: sizeof(num)];
}

-(void) writeUInt16: (UInt16)num {
	[self writeBytes: &num count: sizeof(num)];
}

-(void) writeSInt16: (SInt16)num {
	[self writeBytes: &num count: sizeof(num)];
}

-(void) writeUInt32: (UInt32)num {
	[self writeBytes: &num count: sizeof(num)];
}

-(void) writeSInt32: (SInt32)num {
	[self writeBytes: &num count: sizeof(num)];
}

-(void) writeFloat: (float)num {
	[self writeBytes: &num count: sizeof(num)];
}

-(void) writeDouble: (double)num {
	[self writeBytes: &num count: sizeof(num)];
}

-(void) writeBoolean: (Boolean)num {
	[self writeBytes: &num count: sizeof(num)];
}

-(void) writeStr255: (Str255)str {
	[self writeBytes: str count: str[0] + 1];
}

-(void) writeCStr: (const char*)str {
	[self writeBytes: str count: strlen(str) + 1];
}

-(void) writeRect: (Rect)box {
	[self writeBytes: &box count: sizeof(box)];
}

@end
