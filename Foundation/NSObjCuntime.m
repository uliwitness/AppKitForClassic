#import "NSObjCRuntime.h"
#include <stdio.h>
#include <DateTimeUtils.h>

void NSLog(NSString *fmtObj, ...) {
	unsigned long dateTime = 0;
	NSString *formattedMsg = nil;
	Str255 dateStr = {0};
	va_list ap;
	va_start(ap, fmtObj);
	formattedMsg = [[NSString alloc] initWithFormat: fmtObj arguments: ap];
	va_end(ap);
	
	putc('[', stdout);
	GetDateTime(&dateTime);
	IUDateString(dateTime, shortDate, dateStr);
	fwrite(dateStr + 1, 1, dateStr[0], stdout);
	putc(' ', stdout);
	IUTimeString(dateTime, true, dateStr);
	fwrite(dateStr + 1, 1, dateStr[0], stdout);
	fwrite("] ", 1, 2, stdout);
	fwrite([formattedMsg cString], 1, [formattedMsg length], stdout);
	putc('\n', stdout);
	[formattedMsg release];
}