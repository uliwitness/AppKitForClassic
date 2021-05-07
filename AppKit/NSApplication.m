#import "NSApplication.h"#import "NSAutoreleasePool.h"#import "NSEvent.h"#import "NSMenu.h"#import "NSMenuItem.h"#import "NSWindow.h"#import "NSMenu.h"#include <Resources.h>#include <Menus.h>#include <MacWindows.h>#include <MacMemory.h>#include <Quickdraw.h>#include <TextEdit.h>#include <Dialogs.h>NSApplication* NSApp = nil;@implementation NSApplication+(NSApplication*) sharedApplication{	if( !NSApp ) {		NSApp = [[NSApplication alloc] init];	}		return NSApp;}-(id) init{	self = [super init];	if( self ) {		int x;		_isRunning = YES;				for(x = 0; x < 4; ++x) {			MoreMasters();		}				InitGraf(&qd.thePort);		InitFonts();		InitWindows();		InitMenus();		TEInit();		InitDialogs(NULL);		InitCursor();		InitResources();				GetDateTime((unsigned long*) &qd.randSeed);	}	return self;}-(void) setDelegate: (id<NSApplicationDelegate>)dele{	NSObject* oldDelegate = _delegate;	_delegate = [(NSObject*)dele retain];	[oldDelegate release];}-(id<NSApplicationDelegate>) delegate{	return _delegate;}-(void) run{	NSAutoreleasePool * pool = nil;	WindowPtr currentWindow = NULL;	NSWindow * windowObject = NULL;	WindowPartCode part = inNoWindow;	EventRecord event = {};	NSEvent *eventObject = nil;	_isRunning = YES;		pool = [[NSAutoreleasePool alloc] init];		[_mainMenu install];		[_delegate applicationDidFinishLaunching];			while( _isRunning ) {		[pool release];		pool = [[NSAutoreleasePool alloc] init];		if( !WaitNextEvent( everyEvent, &event, 10, NULL ) ) {			continue;		}		switch( event.what ) {			case mouseDown:				part = FindWindow(event.where, &currentWindow);				windowObject = (NSWindow*) GetWRefCon(currentWindow);				switch( part ) {					case inMenuBar: {						[self handleMenuChoice: MenuSelect( event.where )];						break;					}										case inSysWindow:						SystemClick( &event, currentWindow );						break;										case inGoAway:						if( TrackGoAway( currentWindow, event.where ) ) {							[windowObject performClose: nil];						}						break;										case inContent:						eventObject = [[[NSEvent alloc] initWithMacEvent: &event window: windowObject] autorelease];						[windowObject mouseDown: eventObject];						break;										case inDrag:						DragWindow( currentWindow, event.where, &(**GetGrayRgn()).rgnBBox);						break;											case inGrow:					{						Rect limits = { 100, 100, 32767, 32767 };						long newSize = GrowWindow( currentWindow, event.where, &limits );						if( newSize != 0 ) {							[windowObject setSize: NSMakeSize(newSize & 0xffff, (newSize & 0xffff0000) >> 16)];						}						break;					}				}				break;						case activateEvt:				currentWindow = (WindowPtr)event.message;				windowObject = (NSWindow*) GetWRefCon(currentWindow);				[windowObject activate];				break;						case keyDown:				if( event.modifiers & cmdKey ) {					long menuAndItem = MenuKey(event.message & charCodeMask);					DrawMenuBar();					[self handleMenuChoice: menuAndItem];				} else {					eventObject = [[[NSEvent alloc] initWithMacEvent: &event window: nil] autorelease];					[self tryToPerform: @selector(keyDown:) withObject: eventObject];				}				break;						case updateEvt:			{				GrafPtr oldPort = NULL;				GetPort( &oldPort );				currentWindow = (WindowPtr)event.message;				windowObject = (NSWindow*) GetWRefCon(currentWindow);				SetPort( currentWindow );				BeginUpdate( currentWindow );				[windowObject draw];				EndUpdate( currentWindow );				ValidRect( &currentWindow->portRect );				SetPort( oldPort );				break;			}		}	}	[pool release];	pool = [[NSAutoreleasePool alloc] init];	[_delegate applicationWillTerminate];		[pool release];}-(BOOL) handleMenuChoice: (long)menuAndItem{	BOOL result = NO;	if( menuAndItem != 0L ) {		ResID menuID = (menuAndItem & 0xffff0000) >> 16;		short chosenItem = (menuAndItem & 0x0000ffff);		NSMenu * foundMenu = [_mainMenu menuByID: menuID];		if( foundMenu ) {			NSMenuItem * foundItem = [[foundMenu itemArray] objectAtIndex: chosenItem - 1];			[[foundItem target] performSelector: [foundItem action] withObject: foundItem];			result = YES;		}		Delay(10, NULL);		HiliteMenu(0);	}		return result;}-(void) terminate: (id)sender{	_isRunning = NO;}-(void) setMainMenu: (NSMenu*)menu{	NSMenu * oldMenu = _mainMenu;	_mainMenu = [menu retain];	[oldMenu release];}-(NSMenu*) mainMenu{	return _mainMenu;}-(NSWindow*) mainWindow{	WindowPtr frontWindow = FrontWindow();	if( !frontWindow ) {		return nil;	}	return [NSWindow windowFromMacWindow: frontWindow];}-(NSResponder*) firstResponder{	NSResponder *firstResponder = [[self mainWindow] firstResponder];	if( !firstResponder ) {		firstResponder = self;	}	return firstResponder;}-(BOOL) tryToPerform: (SEL)action withObject:(id)object {	NSResponder * currentResponder = [self firstResponder];	while( currentResponder ) {		if( [currentResponder respondsToSelector: action] ) {			[currentResponder performSelector: action withObject: object];			return YES;		}		currentResponder = [currentResponder nextResponder];	}	return NO;}@end