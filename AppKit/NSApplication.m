#import "NSApplication.h"
#import "NSAutoreleasePool.h"
#import "NSEvent.h"
#import "NSMenu.h"
#import "NSMenuItem.h"
#import "NSWindow.h"
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
	mouseRgn = NewRgn();

	_isRunning = YES;
	
	pool = [[NSAutoreleasePool alloc] init];
	
	[_mainMenu install];
	
	[_delegate applicationDidFinishLaunching];
	
	while( _isRunning ) {
		unsigned long nextFireTime = [NSTimer fireTimersAt: TickCount()];
		[pool release];
		pool = [[NSAutoreleasePool alloc] init];
		GetMouse(&mousePos);
		SetRectRgn(mouseRgn, mousePos.h, mousePos.v, mousePos.h + 1, mousePos.v + 1);
	
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
						[self tryToPerform: @selector(mouseMoved:) withObject: eventObject];
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

	[_delegate applicationWillTerminate];
	
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
	NSMutableArray * items;
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
	printf("App About panel! WHOOO!\r");
}

@end
