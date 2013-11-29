//
//  MTDialogues.m
//  MacTwee
//
//  Created by Chris Braithwaite on 11/27/13.
//  Copyright (c) 2013 MacTwee. Released under MIT License.
//

#import "MTDialogues.h"

@implementation MTDialogues


+ (NSURL *)openPanelForFileWithMessage:(NSString *)message {
	NSURL * result;
    
    result = [self runOpenPanel:message fileTypes:nil];
    
	return result;
}

+ (NSURL *)openPanelForFileWithMessage:(NSString *)message fileTypes:(NSArray *)fileTypes {
    NSURL * result;
	
    result = [self runOpenPanel:message fileTypes:fileTypes];
	
	return result;
}

+ (NSURL *)savePanelForFileWithMessage:(NSString *)message fileName:(NSString *)fileName {
    NSURL * result;
	
    NSSavePanel * savepanel = [NSSavePanel savePanel];
	//savepanel.message = message;
	//savepanel.title = @"title";
	//savepanel.prompt = @"prompt";
	savepanel.nameFieldStringValue = fileName;
	savepanel.canCreateDirectories = YES;
    savepanel.showsTagField = YES;
    
	if( [savepanel runModal] == NSFileHandlingPanelOKButton) {
		result = savepanel.URL;
	}
	
	return result;
}


#pragma mark - Private

+ (NSURL *)runOpenPanel:(NSString *)message fileTypes:(NSArray *)fileTypes {
    NSURL *result;
    NSOpenPanel * openPanel = [NSOpenPanel openPanel];
	openPanel.message = message;
    if (fileTypes != nil && fileTypes.count > 0) { openPanel.allowedFileTypes = fileTypes; }
	openPanel.canChooseFiles = YES;
	openPanel.canChooseDirectories = NO;
	openPanel.resolvesAliases = YES;
	openPanel.allowsMultipleSelection = NO;
	
	if ( ([openPanel runModal] == NSOKButton) && ([openPanel URL].isFileURL) ) {
		result = openPanel.URLs[0];
	}
    return result;
}


@end
