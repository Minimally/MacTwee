/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */
#import "CBPreferencesWindowController.h"

@implementation CBPreferencesWindowController

- (IBAction)setTweeLocation:(id)sender {
	[self runPanelForTweeDirectory];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////
- (NSURL *)runPanelForTweeDirectory {// gets the user to specify a directory for twee ? this workflow kinda sucks
	NSURL * result;
	
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	openPanel.allowsMultipleSelection = NO;
	openPanel.canChooseFiles = YES;
	openPanel.canChooseDirectories = NO;
	openPanel.resolvesAliases = YES;
	
	if ( ([openPanel runModal] == NSOKButton) && ([[openPanel URL] isFileURL]) ) {
		result = openPanel.URLs[0];
		[[NSUserDefaults standardUserDefaults] setValue:[result path] forKey:kPathToTwee];
	} else {
		NSLog(@"%s 'Line:%d' - Operation Cancled by user", __func__, __LINE__);
	}
	
	return result;
}
@end
