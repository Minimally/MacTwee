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
	NSDictionary * dict = @{
						 @"exitOnLastClose":@YES,
						 kPathToTwee:[[CBPreferencesManager documentDirectory] path],
	   @"textSize":@14,
	   @"passageColor":[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]],// color as data
	   @"backgroundColor":[NSArchiver archivedDataWithRootObject:[NSColor blackColor]],
	   @"linkColor":[NSArchiver archivedDataWithRootObject:[NSColor blueColor]],
	   @"macroColor":[NSArchiver archivedDataWithRootObject:[NSColor purpleColor]],
	   @"imageColor":[NSArchiver archivedDataWithRootObject:[NSColor yellowColor]],
	   @"htmlColor":[NSArchiver archivedDataWithRootObject:[NSColor orangeColor]],
	   @"commentColor":[NSArchiver archivedDataWithRootObject:[NSColor lightGrayColor]],
	   @"displayColor":[NSArchiver archivedDataWithRootObject:[NSColor greenColor]]
	   };
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:dict];
	[self newDocument:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"exitOnLastClose"];
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
