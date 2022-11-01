#include "AppKit.h"
#include "NSDefaultButtonOutline.h"
#include "NSTabView.h"
#include <stdio.h>

@class MyAppDelegate;

@interface MyAppDelegate : NSObject
{
	NSWindow* _mainWindow;
	NSWindow* _dlogWindow;
}

-(void) applicationDidFinishLaunching;

@end

@implementation MyAppDelegate

-(void) applicationDidFinishLaunching
{
	BOOL focused = NO;
	NSView* innerView = nil;
	NSButton* buttonView = nil;
	NSTextField* textView = nil;
	_mainWindow = [[NSWindow alloc] initWithFrame: NSMakeRect(10, 50, 512, 342) title: @"AppKit on Classic!"];
	innerView = [[[NSView alloc] initWithFrame: NSMakeRect(100, 100, 300, 200)] autorelease];
	[[_mainWindow contentView] addSubview: innerView];
	buttonView = [[[NSButton alloc] initWithFrame: NSMakeRect(30, 50, 100, 22)] autorelease];
	[buttonView setTitle: @"Toot toot!"];
	[buttonView setToolTip: @"This is actually a balloon!!!"];
	textView = [[[NSTextField alloc] initWithFrame: NSMakeRect(12, 130, 200, 100)] autorelease];
	[textView setStringValue: @"The avalanche has already started. It is too late for the pebbles to vote."];
	[innerView setAutoresizingMask: NSViewMinXMargin | NSViewMaxYMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewWidthSizable | NSViewHeightSizable];
	[innerView addSubview: textView];
	[textView addSubview: buttonView];
	focused = [_mainWindow makeFirstResponder: textView];
	[_mainWindow makeKeyAndOrderFront: self];
	
	_dlogWindow = [[NSWindow alloc] initWithDLOG: 128];
	[_dlogWindow makeKeyAndOrderFront: self];
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
	[mainMenu debugPrintWithIndent: 0];
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

