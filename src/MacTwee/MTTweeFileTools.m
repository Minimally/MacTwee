//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import "MTTweeFileTools.h"
#import "MTTweeBuildUtility.h"
#import "MTTweeImportUtility.h"
#import "MTTweeExportUtility.h"
#import "MTPreferencesManager.h"
#import "MTProjectEditor.h"
#import "MTProject.h"


@implementation MTTweeFileTools

MTTweeImportUtility * importUtility;
MTTweeExportUtility * exportUtility;
MTTweeBuildUtility * buildUtility;

#pragma mark - Public

- (void)importTweeFile {
	if (importUtility == nil)
		importUtility = [[MTTweeImportUtility alloc]init];
	
	[importUtility importTweeFile];
}

- (NSURL *)exportTweeFile {
	if (exportUtility == nil)
		exportUtility = [[MTTweeExportUtility alloc]init];
	
	return [exportUtility exportTweeFile];
}

- (void)buildStory {
	//NSLog(@"%s 'Line:%d' ''", __func__, __LINE__);
	if (exportUtility == nil)
		exportUtility = [[MTTweeExportUtility alloc] init];
	if (buildUtility == nil)
		buildUtility = [[MTTweeBuildUtility alloc] init];
	
	NSURL * url = [exportUtility exportTempTweeFile];	
	[buildUtility buildHtmlFileWithSource:url];
}

- (void)buildAndRunStory {
	//NSLog(@"%s 'Line:%d' ''", __func__, __LINE__);
	[self buildStory];
	
	NSString * last = [MTProjectEditor sharedMTProjectEditor].currentProject.buildDirectory;
	
	NSAssert(last != nil, @"last path should not be nil");
	
	if (last != nil) {
		NSFileManager * manager = [[NSFileManager alloc] init];
		if ( [manager fileExistsAtPath:last] ) {
			NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
			[workspace openFile:last];
		}
	}
}


#pragma mark - Private

- (void)operationResultWithTitle:(NSString *)title msgFormat:(NSString *)msgFormat defaultButton:(NSString *)defaultButton {
	NSRunAlertPanel(title, msgFormat, defaultButton, nil, nil);
	//[self operationResultWithTitle:@"Error" msgFormat:@"EXAMPLE" defaultButton:@"OK"];
	//[self operationResultWithTitle:@"Success" msgFormat:@"EXAMPLE" defaultButton:@"OK"];
}


@end
