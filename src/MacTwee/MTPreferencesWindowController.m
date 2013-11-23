//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import "MTPreferencesWindowController.h"


@implementation MTPreferencesWindowController

#pragma mark - IBAction

- (IBAction)setTweeLocation:(id)sender {
	[self runPanelForTweeDirectory];
}


#pragma mark - Private

/// gets the user to specify a directory for twee ? this workflow kinda sucks

- (NSURL *)runPanelForTweeDirectory {
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
