#include "NSCursor.h"
#include <Quickdraw.h>

@interface NSResCursor : NSCursor
{
	short _cursorID;
}

-(id)initWithCURS: (short)cursorID;

-(Cursor *) macCursor;

@end


@implementation NSResCursor

-(id)initWithCURS: (short)cursorID {
	self = [super init];
	if (self) {
		_cursorID = cursorID;
	}
	return self;
}

-(Cursor *) macCursor {
	CursHandle curs = GetCursor(_cursorID);
	return *curs;
}

@end

@interface NSMacCursor : NSCursor
{
	Cursor * _macCursor;
}

-(id)initWithMacCursor: (Cursor*)inCursor;

-(Cursor *) macCursor;

@end


@implementation NSMacCursor

-(id)initWithMacCursor: (Cursor*)inCursor {
	self = [super init];
	if (self) {
		_macCursor = inCursor;
	}
	return self;
}

-(Cursor *) macCursor {
	return _macCursor;
}

@end



@implementation NSCursor

+(NSCursor*) arrowCursor {
	static NSCursor * sCursor = nil;
	if (!sCursor) {
		sCursor = [[NSMacCursor alloc] initWithMacCursor: &qd.arrow];
	}
	return sCursor;
}

+(NSCursor*) IBeamCursor {
	static NSCursor * sCursor = nil;
	if (!sCursor) {
		sCursor = [[NSResCursor alloc] initWithCURS: iBeamCursor];
	}
	return sCursor;
}

+(NSCursor*) crosshairCursor {
	static NSCursor * sCursor = nil;
	if (!sCursor) {
		sCursor = [[NSResCursor alloc] initWithCURS: crossCursor];
	}
	return sCursor;
}

+(NSCursor*) watchCursor {
	static NSCursor * sCursor = nil;
	if (!sCursor) {
		sCursor = [[NSResCursor alloc] initWithCURS: watchCursor];
	}
	return sCursor;
}

+(NSCursor*) pointingHandCursor {
	static NSCursor * sCursor = nil;
	if (!sCursor) {
		sCursor = [[NSResCursor alloc] initWithCURS: 128];
	}
	return sCursor;
}

-(void) set {
	SetCursor([self macCursor]);
}

-(Cursor *) macCursor {
	return NULL;
}

@end
