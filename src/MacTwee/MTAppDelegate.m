//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import "MTAppDelegate.h"
#import "MTCoreDataManager.h"
#import "MTPreferencesManager.h"
#import "MTPrimaryWindowController.h"
#import "MTPreferencesWindowController.h"


@implementation MTAppDelegate {
	MTPrimaryWindowController * primaryWindwowController;
	MTPreferencesWindowController * pref;
}


#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSDictionary * dict = @{
                            @"exitOnLastClose":@YES,
                            kPathToTwee:[[MTPreferencesManager documentDirectory] path],
                            @"textSize":@14,
                            @"passageColor":[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]],// color as data
                            @"backgroundColor":[NSArchiver archivedDataWithRootObject:[NSColor blackColor]],
                            @"linkColor":[NSArchiver archivedDataWithRootObject:[NSColor blueColor]],
                            @"brokenLinkColor":[NSArchiver archivedDataWithRootObject:[NSColor redColor]],
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
    return [[MTCoreDataManager sharedMTCoreDataManager] runTerminateByCoreDataFirst:sender];
}


#pragma mark - IBAction

- (IBAction)newDocument:(id)sender {
	if (primaryWindwowController == nil) {
		primaryWindwowController = [[MTPrimaryWindowController alloc] initWithWindowNibName:@"MTPrimaryWindow"];
        [primaryWindwowController showWindow:self];
        [primaryWindwowController selectView:MTPageHome];
    }
    else {
        NSDictionary * dict = @{ @"index" : [NSNumber numberWithLong:MTMenuBtnNew] };
        [[NSNotificationCenter defaultCenter] postNotificationName:MTAppDelegateDidGetMenuClickNotification
                                                            object:self
                                                          userInfo:dict];
    }
}

- (IBAction)saveDocument:(id)sender {
	[[MTCoreDataManager sharedMTCoreDataManager] save];
}

- (IBAction)preferencesMenuItem:(id)sender {
	if (pref == nil)
		pref = [[MTPreferencesWindowController alloc] initWithWindowNibName:@"MTPreferencesView"];
	[pref.window center];
	[pref showWindow:nil];
}

- (IBAction)homeView:(id)sender {
	if (primaryWindwowController == nil) {
		primaryWindwowController = [[MTPrimaryWindowController alloc] initWithWindowNibName:@"MTPrimaryWindow"];
        [primaryWindwowController showWindow:self];
    }
    [primaryWindwowController selectView:MTPageHome];
}


@end
