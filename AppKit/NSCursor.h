#include "NSMiniRuntime.h"

struct Cursor;

@interface NSCursor : NSObject

+(NSCursor*) arrowCursor;
+(NSCursor*) IBeamCursor;
+(NSCursor*) pointingHandCursor;

+(NSCursor*) crosshairCursor;
+(NSCursor*) watchCursor;

-(void) set;

// private:
-(struct Cursor *) macCursor;

@end
