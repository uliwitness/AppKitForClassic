#import "NSObjCRuntime.h"
#include <stdio.h>

void NSLog(NSString *fmtObj, ...) {
	NSString *formattedMsg = nil;
	va_list ap;
	va_start(ap, fmtObj);
	formattedMsg = [[NSString alloc] initWithFormat: fmtObj arguments: ap];
	va_end(ap);
	
	puts([formattedMsg cString]);
	putc('\n', stdout);
	[formattedMsg release];
}