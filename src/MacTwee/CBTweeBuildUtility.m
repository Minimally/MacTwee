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
	
	if (url != nil && header != nil && header.length > 0) {
		[self buildTweeFileAtPath:[url path] andHeader:header];
	} else {
		[self operationResult:@"Issue with source file url or header"];
	}
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
		[self operationResult:@"couldn't find twee"];
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
	
	NSAssert((compiledHTMLString != nil || compiledHTMLString.length > 0), @"string is nil or empty");
	
	//NSLog(@"%s 'Line:%d' - result from twee: '%@'", __func__, __LINE__, compiledHTMLString);
	
	if ([compiledHTMLString matchesPatternRegexPattern:@"twee: no source files specified"]) {
		[self operationResult:@"twee: no source files specified"];
	} else {
		[self htmlFileWithBuildResult:compiledHTMLString];
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
			[self operationResult:@"saved successfully"];
		} else {
			[self operationResult:[NSString stringWithFormat:@"issue writing html file string to url %@", fileURL]];
		}
	} else {
		[self operationResult:[NSString stringWithFormat:@"url was nil %@", fileURL]];
	}
}

////////////////////////////////////////////////////////////////////////
#pragma mark - User Dialogues
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
		[self operationResult:@"Build cancled"];
	}
	
	return result;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Result
////////////////////////////////////////////////////////////////////////

- (void)operationResult:(NSString *)result {
	NSLog(@"%s 'Line:%d' - %@", __func__, __LINE__, result);
}

@end
