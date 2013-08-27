/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBTweeFileTools.h"
#import "CBTweeBuildUtility.h"
#import "CBTweeImportUtility.h"
#import "CBTweeExportUtility.h"
#import "CBPreferencesManager.h"
#import "CBProjectEditor.h"

@implementation CBTweeFileTools

CBTweeImportUtility * importUtility;
CBTweeExportUtility * exportUtility;
CBTweeBuildUtility * buildUtility;

////////////////////////////////////////////////////////////////////////
#pragma mark - Public
////////////////////////////////////////////////////////////////////////

- (void)importTweeFile {
	if (importUtility == nil)
		importUtility = [[CBTweeImportUtility alloc]init];
	
	[importUtility importTweeFile];
}

- (NSURL *)exportTweeFile {
	if (exportUtility == nil)
		exportUtility = [[CBTweeExportUtility alloc]init];
	
	return [exportUtility exportTweeFile];
}

- (void)buildStory {
	//NSLog(@"%s 'Line:%d' ''", __func__, __LINE__);
	if (exportUtility == nil)
		exportUtility = [[CBTweeExportUtility alloc] init];
	if (buildUtility == nil)
		buildUtility = [[CBTweeBuildUtility alloc] init];
	
	NSURL * url = [exportUtility exportTempTweeFile];
	
	NSString * header = [self getHeader];
	
	[buildUtility buildHtmlFileWithSource:url andHeader:header];
}

- (void)buildAndRunStory {
	//NSLog(@"%s 'Line:%d' ''", __func__, __LINE__);
	[self buildStory];
	
	NSString * last = [[CBPreferencesManager lastBuildDirectory] path];
	
	NSAssert(last != nil, @"last path should not be nil");
	
	if (last != nil) {
		NSFileManager * manager = [[NSFileManager alloc] init];
		if ( [manager fileExistsAtPath:last] ) {
			NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
			[workspace openFile:last];
		}
	}
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////
- (NSString *)getHeader {
	NSString * result = [[CBProjectEditor sharedCBProjectEditor] getStoryFormat];
	
	if (result == nil || result.length == 0) {
		result = @"sugarcane";
	} else {
		NSURL * headerDirectory = [[CBPreferencesManager tweeDirectory] URLByDeletingLastPathComponent];		
		headerDirectory = [headerDirectory URLByAppendingPathComponent:@"targets"];
		headerDirectory = [headerDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", result]];
		//NSLog(@"%s 'Line:%d' - header directory with result added:'%@'", __func__, __LINE__, headerDirectory.path);
				
		NSError * error;
		if ( ![headerDirectory checkResourceIsReachableAndReturnError:&error] ) {
			NSLog(@"%s 'Line:%d' - error with '%@':'%@'", __func__, __LINE__, headerDirectory, error.localizedDescription);
			[self operationResultWithTitle:@"Error" msgFormat:[NSString stringWithFormat:@"%@", error.localizedDescription] defaultButton:@"OK"];
			result = @"sugarcane";
		} else {
			result = [headerDirectory lastPathComponent];
			NSLog(@"%s 'Line:%d' - header is reachable, using:'%@'", __func__, __LINE__, result);
		}
	}
	
	return result;

}
- (void)operationResultWithTitle:(NSString *)title msgFormat:(NSString *)msgFormat defaultButton:(NSString *)defaultButton {
	NSRunAlertPanel(title, msgFormat, defaultButton, nil, nil);
	//[self operationResultWithTitle:@"Error" msgFormat:@"EXAMPLE" defaultButton:@"OK"];
	//[self operationResultWithTitle:@"Success" msgFormat:@"EXAMPLE" defaultButton:@"OK"];
}
@end
