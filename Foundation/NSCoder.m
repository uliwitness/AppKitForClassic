#import "NSCoder.h"

@implementation NSCoder

-(void) encodeObject: (id)obj {
}

-(id) decodeObject {
	return nil;
}

-(void) encodeBool: (BOOL)num {

}

-(BOOL) decodeBool {
	return NO;
}

-(void) encodeInt: (int)num {

}

-(int) decodeInt {
	return 0;
}

-(void) encodeInt32: (SInt32)num {

}

-(int) decodeInt32 {
	return 0;
}

-(void) encodeFloat: (float)num {

}

-(float) decodeFloat {
	return 0;
}

-(void) encodeDouble: (double)num {

}

-(double) decodeDouble {
	return 0;
}

-(void) encodeBytes: (const void *)bytes length: (unsigned)len {

}

-(const void *) decodeBytesReturnedLength: (unsigned*)outLen {
	*outLen = 0;
	return nil;
}

@end
