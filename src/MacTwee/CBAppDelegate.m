/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBAppDelegate.h"
#import "CBCoreDataManager.h"
#import "CBPrimaryWindowController.h"

@implementation CBAppDelegate

CBPrimaryWindowController * primaryWindwowController;

////////////////////////////////////////////////////////////////////////
#pragma mark - Protocol
////////////////////////////////////////////////////////////////////////

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
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
@end
