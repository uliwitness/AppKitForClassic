#import "Foundation.h"
#import "NSEvent.h"
#import "NSResponder.h"
#import <Events.h>

@class NSMenu;

@class NSApplication;

@protocol NSApplicationDelegate

-(void) applicationDidFinishLaunching;
-(void) applicationWillTerminate;

@end

@interface NSApplication : NSResponder
{
	BOOL _isRunning;
	NSObject<NSApplicationDelegate> *_delegate;
	NSMenu *_mainMenu;
}

+(NSApplication*) sharedApplication;

-(void) setDelegate: (id<NSApplicationDelegate>)dele;
-(id<NSApplicationDelegate>) delegate;

-(void) run;

-(void) terminate: (id)sender;

-(void) setMainMenu: (NSMenu*)menu;
-(NSMenu*) mainMenu;

-(NSWindow*) mainWindow;

-(BOOL) tryToPerform: (SEL)action withObject:(id)object;
-(BOOL) sendAction: (SEL)action to: (id)target from: (id)sender;
-(NSResponder*) targetForAction: (SEL)action to:(id)target from: (id)sender;

// Private:
-(BOOL) handleMenuChoice: (long)menuAndItem;

-(NSResponder*) firstResponder;

-(void) validateMenus: (NSMenu*)menu;

@end

extern NSApplication *NSApp;