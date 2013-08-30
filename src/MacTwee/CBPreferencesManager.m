/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBPreferencesManager.h"

@implementation CBPreferencesManager
////////////////////////////////////////////////////////////////////////
#pragma mark - Public
////////////////////////////////////////////////////////////////////////
+ (NSURL *)tweeDirectory {
	NSURL * result = [[NSUserDefaults standardUserDefaults] URLForKey:kPathToTwee];
	
	if (result != nil) {
		NSError * err;
		if ( ![result checkResourceIsReachableAndReturnError:&err] ) {
			NSLog(@"%s 'Line:%d' - got an error '%@'", __func__, __LINE__, err);
			result = nil;
		}
	}
	
	if (result == nil) {
		NSLog(@"%s 'Line:%d' 'twee path key returned nil'", __func__, __LINE__);
		result = [CBPreferencesManager runPanelForTweeDirectory];
	}
	return result;
}

+ (NSString *)lastBuildName {
	NSString * result = [[NSUserDefaults standardUserDefaults] stringForKey:kLastBuildName];
	
	if (result == nil || result.length < 1) {
		result = kdefaultBuildName;
	}
	
	return result;
}
+ (void)setLastBuildName:(NSString *)buildName {
	[[NSUserDefaults standardUserDefaults] setObject:buildName forKey:kLastBuildName];
}

+ (NSString *)lastSourceName {
	NSString * result = [[NSUserDefaults standardUserDefaults] stringForKey:kLastSourceName];
	
	if (result == nil || result.length < 1) {
		result = kdefaultSourceName;
	}
	
	return result;
}
+ (void)setLastSourceName:(NSString *)sourceName {
	[[NSUserDefaults standardUserDefaults] setObject:sourceName forKey:kLastSourceName];
}

+ (NSURL *)lastBuildDirectory {
	NSURL * result = [[NSUserDefaults standardUserDefaults] URLForKey:kLastBuildDirectory];
	
	if (result != nil) {
		NSError * err;
		if ( ![result checkResourceIsReachableAndReturnError:&err] ) {
			NSLog(@"%s 'Line:%d' - got an error '%@'", __func__, __LINE__, err);
			result = nil;
		}
	}
	
	return result;
}
+ (void)setLastBuildDirectory:(NSURL *)directory {
	[[NSUserDefaults standardUserDefaults] setURL:directory forKey:kLastBuildDirectory];
}
+ (void)checkDefaults {
	[CBPreferencesManager colorCheck:@"passageColor" color:[NSColor whiteColor]];
	[CBPreferencesManager colorCheck:@"backgroundColor" color:[NSColor blackColor]];
	[CBPreferencesManager colorCheck:@"linkColor" color:[NSColor blueColor]];
	[CBPreferencesManager colorCheck:@"macroColor" color:[NSColor purpleColor]];
	[CBPreferencesManager colorCheck:@"imageColor" color:[NSColor yellowColor]];
	[CBPreferencesManager colorCheck:@"htmlColor" color:[NSColor orangeColor]];
	[CBPreferencesManager colorCheck:@"commentColor" color:[NSColor lightGrayColor]];
	[CBPreferencesManager colorCheck:@"displayColor" color:[NSColor greenColor]];
	if ( [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"textSize"] == nil)
		[[NSUserDefaults standardUserDefaults] setInteger:14 forKey:@"textSize"];
}
////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////
+ (NSURL *) documentDirectory {
	NSURL * result;
	
	NSArray *documentsFolders = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
	
	if ( [documentsFolders count] > 0 )
		result = documentsFolders[0];
	
	return result;
}
+ (NSURL *)runPanelForTweeDirectory {
	NSURL * result;
	
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	openPanel.allowsMultipleSelection = NO;
	openPanel.message = @"Please select Twee terminal application";
	openPanel.canChooseFiles = YES;
	openPanel.canChooseDirectories = NO;
	openPanel.resolvesAliases = YES;
	
	if ( ([openPanel runModal] == NSOKButton) && ([[openPanel URL] isFileURL]) ) {
		result = openPanel.URLs[0];
		[[NSUserDefaults standardUserDefaults] setURL:result forKey:kPathToTwee];
	} else {
		NSLog(@"%s 'Line:%d' - Operation Cancled by user", __func__, __LINE__);
	}
	
	return result;
}
+ (void)colorCheck:(NSString *)key color:(NSColor *)color {
	if ([[NSUserDefaults standardUserDefaults] valueForKey:key] == nil) {
		NSData * data = [NSArchiver archivedDataWithRootObject:color];
		[[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
	};
}
@end
