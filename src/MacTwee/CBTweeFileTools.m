/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBTweeFileTools.h"
#import "CBTweeBuildUtility.h"
#import "CBTweeImportUtility.h"
#import "CBTweeExportUtility.h"
#import "CBPreferencesManager.h"
#import "CBProjectEditor.h"
#import "CBProject.h"

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
	[buildUtility buildHtmlFileWithSource:url];
}

- (void)buildAndRunStory {
	//NSLog(@"%s 'Line:%d' ''", __func__, __LINE__);
	[self buildStory];
	
	NSString * last = [CBProjectEditor sharedCBProjectEditor].currentProject.buildDirectory;
	
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
- (void)operationResultWithTitle:(NSString *)title msgFormat:(NSString *)msgFormat defaultButton:(NSString *)defaultButton {
	NSRunAlertPanel(title, msgFormat, defaultButton, nil, nil);
	//[self operationResultWithTitle:@"Error" msgFormat:@"EXAMPLE" defaultButton:@"OK"];
	//[self operationResultWithTitle:@"Success" msgFormat:@"EXAMPLE" defaultButton:@"OK"];
}
@end
