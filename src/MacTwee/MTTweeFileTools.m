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
	if (importUtility == nil) importUtility = [[MTTweeImportUtility alloc]init];
	[importUtility importTweeFile];
}

- (NSURL *)exportTweeFile {
	if (exportUtility == nil) exportUtility = [[MTTweeExportUtility alloc]init];
	return [exportUtility exportTweeFile];
}

- (void)buildStory {
	[self buildStory:NO];
}

- (void)buildAndRunStory {
	[self buildStory:YES];
    
	NSString * buildDirectory = [MTProjectEditor sharedMTProjectEditor].currentProject.buildDirectory;
	
    if (buildDirectory != nil) {
		NSFileManager * manager = [[NSFileManager alloc]init];
		if ( [manager fileExistsAtPath:buildDirectory] ) {
			NSWorkspace * workspace = [NSWorkspace sharedWorkspace];
			[workspace openFile:buildDirectory];
		}
	}
}


#pragma mark - Private

/// does the actual build call with values save in MTProjectEditor @param quick YES=no user prompts if possible
- (void)buildStory:(BOOL)quick {
	if (exportUtility == nil) exportUtility = [[MTTweeExportUtility alloc]init];
	NSURL * url = [exportUtility exportTempTweeFile];
    
	if (buildUtility == nil) buildUtility = [[MTTweeBuildUtility alloc]init];
	[buildUtility buildHtmlFileWithSource:url
                           buildDirectory:[MTProjectEditor sharedMTProjectEditor].currentProject.buildDirectory
                            buildFileName:[MTProjectEditor sharedMTProjectEditor].currentProject.buildName
                              storyFormat:[MTProjectEditor sharedMTProjectEditor].currentProject.storyFormat
                               quickBuild:quick];
}


@end
