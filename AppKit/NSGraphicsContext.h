#import "Foundation.h"
(NSGraphicsContext*) currentContext;
(void) setCurrentContext: (NSGraphicsContext*)context;
(void) strokeRect: (NSRect)box;
(void) fillRect: (NSRect)box;
(void) clipRect: (NSRect)box;
(void) strokeLineFromPoint: (NSPoint)start toPoint: (NSPoint)end;