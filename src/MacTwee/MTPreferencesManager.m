//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import "MTPreferencesManager.h"


@implementation MTPreferencesManager


#pragma mark - Public

/// returns the users document directory as a default

+ (NSURL *)documentDirectory {
	NSURL * result;
	NSArray * documentsFolders = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
	if ( [documentsFolders count] > 0 )
		result = documentsFolders[0];
	return result;
}


@end
