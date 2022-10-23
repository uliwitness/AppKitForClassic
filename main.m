#include "AppKit.h"
#include <stdio.h>

@class MyAppDelegate;

@interface MyAppDelegate : NSObject
{
	NSWindow* _mainWindow;
	NSWindow* _dlogWindow;
}

-(void) applicationDidFinishLaunching;
-(void) applicationWillTerminate;

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
	buttonView = [[[NSButton alloc] initWithFrame: NSMakeRect(30, 100, 100, 22)] autorelease];
	[buttonView setTitle: @"Toot toot!"];
	[buttonView setToolTip: @"This is actually a balloon!!!"];
	[[_mainWindow contentView] addSubview: buttonView];
	textView = [[[NSTextField alloc] initWithFrame: NSMakeRect(12, 230, 200, 100)] autorelease];
	[textView setStringValue: @"The avalanche has already started. It is too late for the pebbles to vote."];
	[textView setAutoresizingMask: NSViewMinXMargin | NSViewMaxYMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewWidthSizable | NSViewHeightSizable];
	[[_mainWindow contentView] addSubview: textView];
	focused = [_mainWindow makeFirstResponder: textView];
	[_mainWindow makeKeyAndOrderFront: self];
	
	_dlogWindow = [[NSWindow alloc] initWithDLOG: 128];
	[_dlogWindow makeKeyAndOrderFront: self];
	
	printf("Does this STILL work?\r");
}

-(void) applicationWillTerminate
{
	
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

#if 0
	NSMenu * mainMenu = [[NSMenu alloc] initWithTitle: @"MAIN MENU"];
	NSMenu * appleMenu = [[NSMenu alloc] initWithTitle: @""];
	NSMenu * fileMenu = [[NSMenu alloc] initWithTitle: @"File"];
	NSMenu * editMenu = [[NSMenu alloc] initWithTitle: @"Edit"];
	NSMenuItem * appleMenuParentItem = [[NSMenuItem alloc] initWithTitle: @"-PARENT" target: nil action: NULL keyEquivalent: nil];
	NSMenuItem * fileMenuParentItem = [[NSMenuItem alloc] initWithTitle: @"FILE-PARENT" target: nil action: NULL keyEquivalent: nil];
	NSMenuItem * editMenuParentItem = [[NSMenuItem alloc] initWithTitle: @"EDIT-PARENT" target: nil action: NULL keyEquivalent: nil];
	NSMenuItem * aboutItem = [[NSMenuItem alloc] initWithTitle: @"About AppKitForClassic..." target: nil action: @selector(orderFrontStandardAboutPanel:) keyEquivalent: @"B"];
	NSMenuItem * quitItem = [[NSMenuItem alloc] initWithTitle: @"Quit" target: app action: @selector(terminate:) keyEquivalent: @"Q"];
	NSMenuItem * undoItem = [[NSMenuItem alloc] initWithTitle: @"Undo" target: nil action: @selector(undo:) keyEquivalent: @"Z"];
	NSMenuItem * editPasteboardSeparatorItem = [[NSMenuItem alloc] initWithTitle: @"-" target: nil action: NULL keyEquivalent: nil];
	NSMenuItem * cutItem = [[NSMenuItem alloc] initWithTitle: @"Cut" target: nil action: @selector(cut:) keyEquivalent: @"X"];
	NSMenuItem * copyItem = [[NSMenuItem alloc] initWithTitle: @"Copy" target: nil action: @selector(copy:) keyEquivalent: @"C"];
	NSMenuItem * pasteItem = [[NSMenuItem alloc] initWithTitle: @"Paste" target: nil action: @selector(paste:) keyEquivalent: @"V"];
	NSMenuItem * deleteItem = [[NSMenuItem alloc] initWithTitle: @"Clear" target: nil action: @selector(delete:) keyEquivalent: nil];
	[appleMenuParentItem setSubmenu: appleMenu];
	[fileMenuParentItem setSubmenu: fileMenu];
	[editMenuParentItem setSubmenu: editMenu];
	[mainMenu appendItem: appleMenuParentItem];
	[mainMenu appendItem: fileMenuParentItem];
	[mainMenu appendItem: editMenuParentItem];
	
	[appleMenu appendItem: aboutItem];
	[fileMenu appendItem: quitItem];
	
	[editMenu appendItem: undoItem];
	[editMenu appendItem: editPasteboardSeparatorItem];
	[editMenu appendItem: cutItem];
	[editMenu appendItem: copyItem];
	[editMenu appendItem: pasteItem];
	[editMenu appendItem: deleteItem];
	
	[app performSelector: @selector(setMainMenu:) withObject: mainMenu];
#else
	NSMenu * mainMenu = [NSMenu menuFromMBAR: 128];
	[mainMenu debugPrintWithIndent: 0];
	[app setMainMenu: mainMenu];
#endif
	
	dele = [[MyAppDelegate alloc] init];
	
	[app setDelegate: dele];
	[app run];
	
	return 0;
}

