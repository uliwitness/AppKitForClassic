#import "NSApplication.h"
#import "NSAutoreleasePool.h"
#import "NSEvent.h"
#import "NSMenu.h"
#import "NSMenuItem.h"
#import "NSWindow.h"
#import "NSView.h"
#import "NSMenu.h"
#include <Resources.h>
#include <Menus.h>
#include <MacWindows.h>
#include <MacMemory.h>
#include <Quickdraw.h>
#include <TextEdit.h>
#include <Dialogs.h>
#include <TextUtils.h>
#include <Devices.h>
#include <stdio.h>

NSApplication* NSApp = nil;

@implementation NSApplication

+(NSApplication*) sharedApplication
{
	if( !NSApp ) {
		NSApp = [[NSApplication alloc] init];
	}
	
	return NSApp;
}

-(id) init
{
	self = [super init];
	if( self ) {
		int x;
		_isRunning = YES;
		
		for(x = 0; x < 4; ++x) {
			MoreMasters();
		}
		
		InitGraf(&qd.thePort);
		InitFonts();
		InitWindows();
		InitMenus();
		TEInit();
		InitDialogs(NULL);
		InitCursor();
		InitResources();
		
		GetDateTime((unsigned long*) &qd.randSeed);
	}
	return self;
}

-(void) setDelegate: (id<NSApplicationDelegate>)dele
{
	NSObject* oldDelegate = _delegate;
	_delegate = [(NSObject*)dele retain];
	[oldDelegate release];
}

-(id<NSApplicationDelegate>) delegate
{
	return _delegate;
}


-(void) idleWindows {
	static long sLastIdleTicks = 0;
	WindowPtr currWindow = FrontWindow();
	EventRecord event = { nullEvent, 0UL, 0L, { 0, 0 }, 0U };
	
	if (sLastIdleTicks >= (TickCount() - 5)) {
		return;
	}

	sLastIdleTicks = TickCount();
	event.when = sLastIdleTicks;
	GetMouse(&event.where);
	
	while (currWindow) {
		NSWindow* currWindowObj = (NSWindow*) GetWRefCon(currWindow);
		NSEvent* idleEvt = [[NSEvent alloc] initWithMacEvent: &event window: currWindowObj];
		[currWindowObj idle: nil];
		[idleEvt release];
		currWindow = (WindowPtr) ((WindowPeek)currWindow)->nextWindow;
	}
}


-(void) run
{
	NSAutoreleasePool * pool = nil;
	WindowPtr currentWindow = NULL;
	NSWindow * windowObject = NULL;
	WindowPartCode part = inNoWindow;
	EventRecord event = {};
	NSEvent *eventObject = nil;
	RgnHandle mouseRgn = NULL;
	Point mousePos;
	NSPoint nsMouse;
	NSView *mouseView = nil;
	mouseRgn = NewRgn();
	
	// Make sure app starts with a mouse moved event:
	GetMouse(&mousePos);
	SetRectRgn(mouseRgn, mousePos.h + 10, mousePos.v + 10, mousePos.h + 11, mousePos.v + 11);

	_isRunning = YES;
	
	pool = [[NSAutoreleasePool alloc] init];
	
	[_mainMenu install];
	
	if ([_delegate respondsToSelector: @selector(applicationDidFinishLaunching)]) {
		[(id)_delegate applicationDidFinishLaunching];
	}
	
	while( _isRunning ) {
		unsigned long nextFireTime = [NSTimer fireTimersAt: TickCount()];
		[self idleWindows];
		
		[pool release];
		pool = [[NSAutoreleasePool alloc] init];
		
		if( !WaitNextEvent( everyEvent, &event, nextFireTime, mouseRgn ) ) {
			continue;
		}

		switch( event.what ) {
			case mouseDown:
				part = FindWindow(event.where, &currentWindow);
				windowObject = (NSWindow*) GetWRefCon(currentWindow);
				switch( part ) {
					case inMenuBar: {
						[self validateMenus: [self mainMenu]];
						[self handleMenuChoice: MenuSelect( event.where )];
						break;
					}
					
					case inSysWindow:
						SystemClick( &event, currentWindow );
						break;
					
					case inGoAway:
						if( TrackGoAway( currentWindow, event.where ) ) {
							[windowObject performClose: nil];
						}
						break;
					
					case inContent:
						eventObject = [[[NSEvent alloc] initWithMacEvent: &event window: windowObject] autorelease];
						[windowObject mouseDown: eventObject];
						break;
					
					case inDrag:
						DragWindow( currentWindow, event.where, &(**GetGrayRgn()).rgnBBox);
						break;
						
					case inGrow:
					{
						Rect limits = { 100, 100, 32767, 32767 };
						long newSize = GrowWindow( currentWindow, event.where, &limits );
						if( newSize != 0 ) {
							[windowObject setSize: NSMakeSize(newSize & 0xffff, (newSize & 0xffff0000) >> 16)];
						}
						break;
					}
				}
				break;
			
			case osEvt: {
				UInt32 filteredMsg = (event.message & 0xff000000) >> 24;
				switch( filteredMsg ) {
					case mouseMovedMessage: {
						NSEvent * eventObject;
						eventObject = [[[NSEvent alloc] initWithMacEvent: &event window: nil] autorelease];
						part = FindWindow(event.where, &currentWindow);
						if (part == inContent || part == inGrow) {
							NSWindow * wd = [NSWindow windowFromMacWindow: currentWindow];
							nsMouse = NSPointFromQDPoint(event.where);
							mouseView = [wd _subviewAtPoint: nsMouse];
							if (gCurrentMouseView != mouseView) {
								[gCurrentMouseView mouseExited: eventObject];
								if (mouseView) {
									gCurrentMouseView = mouseView;
									[gCurrentMouseView mouseEntered: eventObject];
									DisposeRgn(mouseRgn);
									mouseRgn = [mouseView _globalRegion];
									SectRgn(mouseRgn, currentWindow->visRgn, mouseRgn);
								} else {
									SetRectRgn(mouseRgn, event.where.h, event.where.v, event.where.h + 1, event.where.v + 1);
									SetCursor(&qd.arrow);
								}
							}
						} else {
							SetRectRgn(mouseRgn, event.where.h, event.where.v, event.where.h + 1, event.where.v + 1);
							SetCursor(&qd.arrow);
						}
						break;
					}
				}
				break;
			}
			
			case activateEvt:
				currentWindow = (WindowPtr)event.message;
				windowObject = (NSWindow*) GetWRefCon(currentWindow);
				if( event.modifiers & activeFlag ) {
					[windowObject activate];
				} else {
					[windowObject deactivate];
				}
				break;
			
			case keyDown: {
				BOOL wasMenu = NO;
				long menuAndItem;
				if( event.modifiers & cmdKey ) {
					[self validateMenus: [self mainMenu]];
					menuAndItem = MenuKey(event.message & charCodeMask);
					DrawMenuBar();
					wasMenu = [self handleMenuChoice: menuAndItem];
				} 
				
				if( !wasMenu ) {
					eventObject = [[[NSEvent alloc] initWithMacEvent: &event window: nil] autorelease];
					[self tryToPerform: @selector(keyDown:) withObject: eventObject];
				}
				break;
			}
			
			case updateEvt:
			{
				GrafPtr oldPort = NULL;
				GetPort( &oldPort );
				currentWindow = (WindowPtr)event.message;
				windowObject = (NSWindow*) GetWRefCon(currentWindow);
				SetPort( currentWindow );
				BeginUpdate( currentWindow );
				[windowObject draw];
				EndUpdate( currentWindow );
				ValidRect( &currentWindow->portRect );
				SetPort( oldPort );
				break;
			}
		}
	}

	[pool release];
	pool = [[NSAutoreleasePool alloc] init];

	if ([_delegate respondsToSelector: @selector(applicationWillTerminate)]) {
		[(id)_delegate applicationWillTerminate];
	}
	
	[pool release];
}

-(BOOL) handleMenuChoice: (long)menuAndItem
{
	BOOL result = NO;
	if( menuAndItem != 0L ) {
		ResID menuID = (menuAndItem & 0xffff0000) >> 16;
		short chosenItem = (menuAndItem & 0x0000ffff);
		NSMenu * foundMenu = [_mainMenu menuByID: menuID];
		if( foundMenu ) {
			NSMenuItem * foundItem = [[foundMenu itemArray] objectAtIndex: chosenItem - 1];
			if( foundItem ) {
				[self sendAction: [foundItem action] to: [foundItem target] from: foundItem];
				result = YES;
			}
		}
	
		if( !result && foundMenu ) {
			Str255 itemText;
			MenuHandle macMenu = [foundMenu macMenu];
			if( EqualString((**macMenu).menuData, "\p", true, true) ) {
				GetMenuItemText( macMenu, chosenItem, itemText );
				OpenDeskAcc( itemText );
				result = YES;
			}
		}
			
		Delay(10, NULL);
		HiliteMenu(0);
	}
	
	return result;
}

-(void) terminate: (id)sender
{
	_isRunning = NO;
}


-(void) setMainMenu: (NSMenu*)menu
{
	NSMenu * oldMenu = _mainMenu;
	_mainMenu = [menu retain];
	[oldMenu release];
}


-(NSMenu*) mainMenu
{
	return _mainMenu;
}

-(NSWindow*) mainWindow
{
	WindowPtr frontWindow = FrontWindow();
	if( !frontWindow ) {
		return nil;
	}
	return [NSWindow windowFromMacWindow: frontWindow];
}

-(NSResponder*) firstResponder
{
	NSResponder *firstResponder = [[self mainWindow] firstResponder];
	if (!firstResponder) {
		firstResponder = [self mainWindow];
	}
	if( !firstResponder ) {
		firstResponder = self;
	}
	return firstResponder;
}

-(BOOL) tryToPerform: (SEL)action withObject:(id)object {
	NSResponder * currentResponder = [self targetForAction: action to:nil from: self];
	if( currentResponder ) {
		[currentResponder performSelector: action withObject: object];
		return YES;
	}
	return NO;
}

-(BOOL) sendAction: (SEL)action to: (id)target from: (id)sender
{
	if( target == nil ) {
		return [self tryToPerform: action withObject: sender];
	} else {
		[target performSelector: action withObject: sender];
		return YES;
	}
}

-(NSResponder*) targetForAction: (SEL)action to:(id)target from: (id)sender
{
	NSResponder * currentResponder;
	if( [target respondsToSelector: action] ) {
		return target;
	}

	currentResponder = [self firstResponder];
	while( currentResponder ) {
		if( [currentResponder respondsToSelector: action] ) {
			return currentResponder;
		}
		currentResponder = [currentResponder nextResponder];
	}
	
	return nil;
}

-(void) validateMenus: (NSMenu*)menu
{
	NSArray * items;
	unsigned x, count;
	NSMenu * submenu;

	items = [menu itemArray];
	count = [items count];
	for( x = 0; x < count; ++x ) {
		NSMenuItem * item = [items objectAtIndex: x];
		NSObject<NSMenuItemTarget> *target = [item target];
		SEL action = [item action];
		if( target || action ) {
			NSObject<NSMenuItemTarget> *realTarget = [self targetForAction: [item action] to: target from: item];
			BOOL shouldEnable = realTarget != nil;
			if( shouldEnable && [realTarget respondsToSelector: @selector(validateMenuItem:)] ) {
				shouldEnable = [(id)realTarget validateMenuItem: item];
			}
			[item setEnabled: shouldEnable];
		}
		
		submenu = [item submenu];
		if( submenu ) {
			[self validateMenus: submenu];
		}
	}
}

-(void) orderFrontStandardAboutPanel: (id)sender
{
	printf("App About panel! WHOOO!\n");
}

@end
