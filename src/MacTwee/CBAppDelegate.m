/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBAppDelegate.h"
#import "CBCoreDataManager.h"
#import "CBPreferencesManager.h"
#import "CBPrimaryWindowController.h"
#import "CBPreferencesWindowController.h"

@implementation CBAppDelegate {
	CBPrimaryWindowController * primaryWindwowController;
	CBPreferencesWindowController * pref;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Protocol
////////////////////////////////////////////////////////////////////////

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[CBPreferencesManager checkDefaults];
	[self newDocument:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    return [[CBCoreDataManager sharedCBCoreDataManager] runTerminateByCoreDataFirst:sender];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Public
////////////////////////////////////////////////////////////////////////

- (IBAction)newDocument:(id)sender {
	if (primaryWindwowController == nil)
		primaryWindwowController = [[CBPrimaryWindowController alloc] initWithWindowNibName:@"CBPrimaryWindow"];
	
	[primaryWindwowController showWindow:self];
	[primaryWindwowController selectView:CBPageHome];
}
- (IBAction)saveDocument:(id)sender {
	[[CBCoreDataManager sharedCBCoreDataManager] save];
}
- (IBAction)preferencesMenuItem:(id)sender {
	if (pref == nil)
		pref = [[CBPreferencesWindowController alloc] initWithWindowNibName:@"CBPreferencesView"];
	
	NSLog(@"Is of type: %@", [pref className]);
	
	[[pref window] center];
	
	[pref showWindow:nil];
}
@end
