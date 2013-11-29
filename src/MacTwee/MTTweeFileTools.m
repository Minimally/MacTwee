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
#import "MTDialogues.h"


@implementation MTTweeFileTools

MTTweeImportUtility * importUtility;
MTTweeExportUtility * exportUtility;
MTTweeBuildUtility * buildUtility;


NSString * const exportMessage = @"Choose export destination";


#pragma mark - Public

- (void)importTweeFile {
	if (importUtility == nil) importUtility = [[MTTweeImportUtility alloc]init];
	[importUtility importTweeFile];
    importUtility = nil;
}

- (NSURL *)exportTweeFile {
    NSURL * result;
    
    [[MTProjectEditor sharedMTProjectEditor] applyExportRules];
    
	if (exportUtility == nil) exportUtility = [[MTTweeExportUtility alloc]init];
    
    NSString * saveName = [MTProjectEditor sharedMTProjectEditor].currentProject.sourceName;
    NSURL * destination = [MTDialogues savePanelForFileWithMessage:exportMessage fileName:saveName];
    
    result = [exportUtility exportTweeFileFromProject:[MTProjectEditor sharedMTProjectEditor].currentProject toDestination:destination];
    
    if (result != nil) {
        [MTProjectEditor sharedMTProjectEditor].currentProject.sourceName = result.lastPathComponent;
    }
    
    exportUtility = nil;
    
	return result;
}

- (void)buildStory {
	[self buildStory:NO];
}

- (void)buildAndRunStory {
	BOOL success = [self buildStory:YES];
    if (!success) { return; }
    
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
- (BOOL)buildStory:(BOOL)quick {
    BOOL result = YES;
    
    [[MTProjectEditor sharedMTProjectEditor] applyExportRules];
    
	if (exportUtility == nil) exportUtility = [[MTTweeExportUtility alloc]init];
	NSURL * url = [exportUtility exportScratchTweeFileFromProject:[MTProjectEditor sharedMTProjectEditor].currentProject];
    exportUtility = nil;
    
    if (url == nil) {
        result = NO;
    }
    
    if (result) {
        if (buildUtility == nil) buildUtility = [[MTTweeBuildUtility alloc]init];
        
        NSURL * buildDirectory;
        NSString * projectBuildDirectory = [MTProjectEditor sharedMTProjectEditor].currentProject.buildDirectory;
        if (projectBuildDirectory != nil && projectBuildDirectory.length != 0) {
            buildDirectory = [NSURL fileURLWithPath:projectBuildDirectory];
        }
        
        result = [buildUtility buildHtmlFileWithSource:url
                                        buildDirectory:buildDirectory
                                           storyFormat:[MTProjectEditor sharedMTProjectEditor].currentProject.storyFormat
                                            quickBuild:quick];
    }
	
    return result;
}


@end
