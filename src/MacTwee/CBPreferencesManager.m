/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBPreferencesManager.h"

@implementation CBPreferencesManager
////////////////////////////////////////////////////////////////////////
#pragma mark - Public
////////////////////////////////////////////////////////////////////////
+ (NSURL *) documentDirectory {// returns the users document directory as a default
	NSURL * result;
	NSArray *documentsFolders = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
	if ( [documentsFolders count] > 0 )
		result = documentsFolders[0];
	return result;
}
@end
