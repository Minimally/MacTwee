/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBTweeBuildUtility.h"
#import "NSString+PDRegex.h"
#import "CBPreferencesManager.h"

@implementation CBTweeBuildUtility

NSString * const promptBuild = @"Choose build destination";

////////////////////////////////////////////////////////////////////////
#pragma mark - Public
////////////////////////////////////////////////////////////////////////
- (void)buildHtmlFileWithSource:(NSURL *)url andHeader:(NSString *)header {
	NSAssert(url != nil, @"url is nil");
	NSAssert((header != nil || header.length > 0), @"string is nil or empty");
	
	if (url == nil) {
		[self operationResultWithTitle:@"Error" msgFormat:@"Issue with html build destination" defaultButton:@"OK"];
		return;
	}
	
	if (header == nil || header.length == 0) {
		[self operationResultWithTitle:@"Error" msgFormat:[NSString stringWithFormat:@"Issue with header '%@'",header] defaultButton:@"OK"];
		return;
	}
	
	[self buildTweeFileAtPath:[url path] andHeader:header];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////
- (void)buildTweeFileAtPath:(NSString *)path andHeader:(NSString *)header {
	NSLog(@"%s 'Line:%d' - path:'%@' header:'%@'", __func__, __LINE__, path, header);
	NSAssert(path != nil, @"url is nil");
	NSAssert((header != nil || header.length > 0), @"string is nil or empty");
	
	NSString * locationOfTwee = [[CBPreferencesManager tweeDirectory] path];
	
	if (locationOfTwee == nil || locationOfTwee.length == 0) {
		[self operationResultWithTitle:@"Error" msgFormat:@"Issue location twee file" defaultButton:@"OK"];
		return;
	}
	
	NSPipe *outputPipe;
	outputPipe = [NSPipe pipe];// we need to use a pipe to collect the data from twee build command
	
	NSTask *task;
	task = [[NSTask alloc] init];
	task.launchPath = locationOfTwee; // where the process exists
	task.arguments =  @[ @"-t", header, path, @">", @"irrelevant.html" ];
	task.standardOutput = outputPipe;
	task.standardInput = [NSPipe pipe];
	
	// we will use a notification for when the process is done
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buildOperationDone:) name:NSFileHandleReadToEndOfFileCompletionNotification object:[outputPipe fileHandleForReading]];
    [[outputPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
	
	[task launch];
	[task waitUntilExit];
}
- (void)buildOperationDone:(NSNotification *)notification {
	//NSLog(@"%s 'Line:%d' - notification:'%@'", __func__, __LINE__, notification);
	
	NSAssert(notification != nil, @"notification is nil");
	
	NSString *compiledHTMLString = [[NSString alloc] initWithData:[[notification userInfo] objectForKey:NSFileHandleNotificationDataItem] encoding:NSUTF8StringEncoding];
	
	//NSAssert((compiledHTMLString != nil), @"compiledHTMLString is nil");
	//NSAssert((compiledHTMLString.length > 0), @"compiledHTMLString is empty");
	
	if ( compiledHTMLString == nil || compiledHTMLString.length == 0 ) {
		[self operationResultWithTitle:@"Error" msgFormat:@"Build operation returned nil" defaultButton:@"OK"];
	} else {
		if ([compiledHTMLString matchesPatternRegexPattern:@"twee: no source files specified"]) {
			[self operationResultWithTitle:@"Error" msgFormat:@"twee: no source files specified" defaultButton:@"OK"];
		} else {
			[self htmlFileWithBuildResult:compiledHTMLString];
		}
	}
	
	
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSFileHandleReadToEndOfFileCompletionNotification
												  object:[notification object]];
}
- (void)htmlFileWithBuildResult:(NSString *)resultString {
	NSAssert((resultString != nil || resultString.length > 0), @"string is nil or empty");
	
	NSURL *fileURL = [self getSaveDestination];
	
	if( fileURL != nil) {
		if ([resultString writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
			[CBPreferencesManager setLastBuildDirectory:fileURL];
		} else {
			[self operationResultWithTitle:@"Error" msgFormat:[NSString stringWithFormat:@"issue writing html file string to url '%@'", fileURL] defaultButton:@"OK"];
		}
	}
}

////////////////////////////////////////////////////////////////////////
#pragma mark - User Dialogues & Results
////////////////////////////////////////////////////////////////////////
- (NSURL *)getSaveDestination {
	NSURL * result;
	
	NSSavePanel *savepanel = [NSSavePanel savePanel];
	savepanel.canCreateDirectories = YES;
	savepanel.nameFieldStringValue = [CBPreferencesManager lastBuildName];
	savepanel.message = promptBuild;
	
	if( [savepanel runModal] == NSFileHandlingPanelOKButton) {
		result = savepanel.URL;
		[CBPreferencesManager setLastBuildName:[result lastPathComponent]];
	} else {
		[self operationResultWithTitle:@"Error" msgFormat:@"Build Operation Canceled" defaultButton:@"OK"];
	}
	
	return result;
}
- (void)operationResultWithTitle:(NSString *)title msgFormat:(NSString *)msgFormat defaultButton:(NSString *)defaultButton {
	NSLog(@"%s 'Line:%d' - msgFormat:'%@'", __func__, __LINE__, msgFormat);
	NSAssert(title != nil, @"title is nil");
	NSAssert(msgFormat != nil, @"msgFormat is nil");
	NSAssert(defaultButton != nil, @"defaultButton is nil");
	NSRunAlertPanel(title, msgFormat, defaultButton, nil, nil);
	//[self operationResultWithTitle:@"Error" msgFormat:@"EXAMPLE" defaultButton:@"OK"];
	//[self operationResultWithTitle:@"Success" msgFormat:@"EXAMPLE" defaultButton:@"OK"];
}

@end
