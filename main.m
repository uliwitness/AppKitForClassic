#include "AppKit.h"
#include "NSDefaultButtonOutline.h"
#include "NSTabView.h"
#include <stdio.h>

@class MyAppDelegate;

@interface MyAppDelegate : NSObject
{
	NSWindow* _mainWindow;
	NSWindow* _dlogWindow;
	int _intVar;
	unsigned _unsignedVar;
	long _longVar;
	unsigned long _unsignedLongVar;
	BOOL _boolVar;
}

-(void) applicationDidFinishLaunching;

@end

@implementation MyAppDelegate

-(void) applicationDidFinishLaunching
{
	BOOL focused = NO;
	NSBox* innerView = nil;
	NSButton* buttonView = nil;
	NSTextField* textView = nil;
	NSMutableDictionary* dict = nil;
	NSMutableArray * arr = nil;
	NSEnumerator* enny = nil;
	NSString* currKey = nil;
	_mainWindow = [[NSWindow alloc] initWithFrame: NSMakeRect(10, 50, 512, 342) title: @"AppKit on Classic!"];
	innerView = [[[NSBox alloc] initWithFrame: NSMakeRect(100, 100, 300, 200)] autorelease];
	[innerView setTitle: @"Boxing day!"];
	[innerView setFillColor: [NSColor whiteColor]];
	[[_mainWindow contentView] addSubview: innerView];
	buttonView = [[[NSButton alloc] initWithFrame: NSMakeRect(30, 50, 100, 22)] autorelease];
	[buttonView setTitle: @"Toot toot!"];
	[buttonView setToolTip: @"This is actually a balloon!!!"];
	textView = [[[NSTextField alloc] initWithFrame: NSMakeRect(12, 130, 200, 100)] autorelease];
	[textView setStringValue: @"The avalanche has already started. It is too late for the pebbles to vote."];
	[innerView setAutoresizingMask: NSViewMinXMargin | NSViewMaxYMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewWidthSizable | NSViewHeightSizable];
	[innerView addSubview: textView];
	[textView addSubview: buttonView];
	[_mainWindow makeKeyAndOrderFront: self];
	
	_dlogWindow = [[NSWindow alloc] initWithDLOG: 128];
	[_dlogWindow makeKeyAndOrderFront: self];
	
	_intVar = -42;
	_unsignedVar = 666;
	_longVar = -100000;
	_unsignedLongVar = 500000;
	_boolVar = YES;
	
	NSLog(@"_mainWindow = %@", [self valueForKey: @"_mainWindow"]);
	NSLog(@"_intVar = %@", [self valueForKey: @"_intVar"]);
	NSLog(@"_unsignedVar = %@", [self valueForKey: @"_unsignedVar"]);
	NSLog(@"_longVar = %@", [self valueForKey: @"_longVar"]);
	NSLog(@"_unsignedLongVar = %@", [self valueForKey: @"_unsignedLongVar"]);
	NSLog(@"_boolVar = %@", [self valueForKey: @"_boolVar"]);
	
	[self setValue: [NSNumber numberWithUnsignedLong: 1000000000] forKey: @"_unsignedLongVar"];
	NSLog(@"_unsignedLongVar = %lu", _unsignedLongVar);
	
	dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject: @"Hey a value!" forKey: @"the key"];
	[dict setObject: @"Another value?" forKey: @"KEYBLOO"];
	
	NSLog(@"Dictionary Contents:");
	enny = [dict keyEnumerator];
	while ((currKey = [enny nextObject])) {
		NSLog(@"\t%@ = %@", currKey, [dict objectForKey: currKey]);
	}
	
	arr = [NSMutableArray arrayWithObjects: @"E", @"A", @"C", @"B", nil];
	NSLog(@"Array Contents: %@", [arr description]);
	[arr sortUsingSelector: @selector(compare:)];
	NSLog(@"Sorted Array Contents: %@", arr);
	
	NSLog(@"A == E: %d", [@"A" compare: @"E"]);
	NSLog(@"A == A: %d", [@"A" compare: @"A"]);
	NSLog(@"E == A: %d", [@"E" compare: @"A"]);
}

@end


int main( void )
{
	void* testISA = (void*) 0x00080005;
	unsigned short refCount = RETAINCOUNT_FROM_ISA(testISA);
	unsigned short classIndex = CLASS_INDEX_FROM_ISA(testISA);
	void* rebuiltISA = ISA_FOR_INDEX_AND_REFCOUNT(classIndex, refCount);
		
	NSApplication *app = [NSApplication sharedApplication];
	NSObject<NSApplicationDelegate> *dele;

	NSMenu * mainMenu = [NSMenu menuFromMBAR: 128];
	//[mainMenu debugPrintWithIndent: 0];
	[app setMainMenu: mainMenu];

	printf("Built menus.\n");
	
	objc_registerClass([NSProgressIndicator class]);
	objc_registerClass([NSDefaultButtonOutline class]);
	objc_registerClass([NSTabView class]);

	dele = [[MyAppDelegate alloc] init];
	
	[app setDelegate: dele];
	[app run];
	
	return 0;
}

