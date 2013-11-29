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
	
	NSOpenPanel * openPanel = [NSOpenPanel openPanel];
	openPanel.message = message;
	openPanel.canChooseFiles = YES;
	openPanel.canChooseDirectories = NO;
	openPanel.resolvesAliases = YES;
	openPanel.allowsMultipleSelection = NO;
	
	if ( ([openPanel runModal] == NSOKButton) && ([openPanel URL].isFileURL) ) {
		result = openPanel.URLs[0];
	}
	
	return result;
}


+ (NSURL *)savePanelForFile:(NSString *)message fileName:(NSString *)fileName {
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


@end
