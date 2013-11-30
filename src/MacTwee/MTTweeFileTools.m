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
NSString * const importMessage = @"Choose a twee source file to import";

#pragma mark - Public

- (void)importTweeFile {
	if (importUtility == nil) importUtility = [[MTTweeImportUtility alloc]init];
	
    NSArray * tweeFileTypes = @[ @"txt", @"twee", @"tw" ];
    NSURL * source = [MTDialogues openPanelForFileWithMessage:importMessage fileTypes:tweeFileTypes];
    if (source != nil) {
        [importUtility importTweeFile:source toProject:[MTProjectEditor sharedMTProjectEditor].currentProject];
    }
    importUtility = nil;
}

- (NSURL *)exportTweeFile {
    NSURL * result;
    
    [[MTProjectEditor sharedMTProjectEditor] applyExportRules];
    
	if (exportUtility == nil) exportUtility = [[MTTweeExportUtility alloc]init];
    
    NSString * saveName = [MTProjectEditor sharedMTProjectEditor].currentProject.sourceName;
    NSURL * destination = [MTDialogues savePanelForFileWithMessage:exportMessage fileName:saveName];
    
    if (destination != nil) {
        result = [exportUtility exportTweeFileFromProject:[MTProjectEditor sharedMTProjectEditor].currentProject toDestination:destination];
    }
    
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
        BOOL internal = [[NSUserDefaults standardUserDefaults] boolForKey:kRunInWebView];
        
        if (internal ) { // open in internal webView
            NSDictionary * dict = @{ @"index":buildDirectory };
            [[NSNotificationCenter defaultCenter] postNotificationName:MTTweeFileToolsDidGetBuiltFile object:self userInfo:dict];
        }
        
        else { // open with default browser
            NSFileManager * manager = [[NSFileManager alloc]init];
            if ( [manager fileExistsAtPath:buildDirectory] ) {
                NSWorkspace * workspace = [NSWorkspace sharedWorkspace];
                [workspace openFile:buildDirectory];
            }
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
    
    if (url == nil) { // export failed
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
