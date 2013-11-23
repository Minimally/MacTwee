//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import "MTTweeBuildUtility.h"
#import "NSString+PDRegex.h"
#import "MTPreferencesManager.h"
#import "MTProjectEditor.h"
#import "MTProject.h"


@implementation MTTweeBuildUtility

NSString * const promptBuild = @"Choose build destination";
NSString * const promptTwee = @"Please select Twee terminal application";


#pragma mark - Public

- (void)buildHtmlFileWithSource:(NSURL *)url {
	[self buildHtmlFileWithSource:url andHeader:@"sugarcane"];
}

- (void)buildHtmlFileWithSource:(NSURL *)url andHeader:(NSString *)header {
	NSAssert(url != nil, @"url is nil");
	NSAssert((header != nil || header.length > 0), @"string is nil or empty");
	
	if (url == nil) {
		[self operationResultWithTitle:@"Error" msgFormat:@"Issue with html build destination" defaultButton:@"OK"];
		return;
	}
	
	if (header == nil || header.length == 0) {
		[self operationResultWithTitle:@"Error" msgFormat:[NSString stringWithFormat:@"Issue with story format"] defaultButton:@"OK"];
		return;
	}
	
	[self buildTweeFileAtPath:[url path] andHeader:header];
}


#pragma mark - Private

- (void)buildTweeFileAtPath:(NSString *)path andHeader:(NSString *)header {
	NSLog(@"%s 'Line:%d' - path:'%@' header:'%@'", __func__, __LINE__, path, header);
	NSAssert(path != nil, @"url is nil");
	NSAssert((header != nil || header.length > 0), @"string is nil or empty");
	
	NSString * locationOfTwee = [self getTwee];
	NSAssert((locationOfTwee != nil || locationOfTwee.length > 0), @"locationOfTwee is nil or empty");
	
	if (locationOfTwee == nil || locationOfTwee.length == 0) {
		[self operationResultWithTitle:@"Error" msgFormat:@"Cannot locate twee file" defaultButton:@"OK"];
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
	
	NSString *compiledHTMLString = [[NSString alloc] initWithData:[notification userInfo][NSFileHandleNotificationDataItem] encoding:NSUTF8StringEncoding];
	
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
			[MTProjectEditor sharedMTProjectEditor].currentProject.buildDirectory = fileURL.path;
		} else {
			[self operationResultWithTitle:@"Error" msgFormat:[NSString stringWithFormat:@"issue writing html file string to url '%@'", fileURL] defaultButton:@"OK"];
		}
	}
}


#pragma mark - User Dialogues & Results

- (NSString *)getTwee {
	NSString * result;NSURL * urlCheck;
	
	// try user defaults
	result = [[NSUserDefaults standardUserDefaults] stringForKey:kPathToTwee]; //NSLog(@"%s 'Line:%d' - result:'%@'", __func__, __LINE__, result);
	urlCheck = [NSURL fileURLWithPath:result isDirectory:NO];
	
	if ( ! [[urlCheck lastPathComponent] isEqualToString:@"twee"] ) {
		// ask user
		urlCheck = [self runPanelForTweeDirectory];
		if ( ! [[urlCheck lastPathComponent] isEqualToString:@"twee"] ) {
			result = nil;
		} else {
			result = [urlCheck path]; //NSLog(@"%s 'Line:%d' - result:'%@'", __func__, __LINE__, result);
		}
	}
	
	return result;
}

- (NSURL *)runPanelForTweeDirectory {// gets the user to specify a directory for twee ? this workflow kinda sucks
	NSURL * result;
	
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	openPanel.allowsMultipleSelection = NO;
	openPanel.message = promptTwee;
	openPanel.canChooseFiles = YES;
	openPanel.canChooseDirectories = NO;
	openPanel.resolvesAliases = YES;
	
	if ( ([openPanel runModal] == NSOKButton) && ([[openPanel URL] isFileURL]) ) {
		result = openPanel.URLs[0];
		[[NSUserDefaults standardUserDefaults] setValue:[result path] forKey:kPathToTwee];
	} else {
		NSLog(@"%s 'Line:%d' - Operation Cancled by user", __func__, __LINE__);
	}
	
	return result;
}

- (NSURL *)getSaveDestination {
	NSURL * result;
	
	NSSavePanel *savepanel = [NSSavePanel savePanel];
	savepanel.canCreateDirectories = YES;
	savepanel.nameFieldStringValue = [MTProjectEditor sharedMTProjectEditor].currentProject.buildName;
	savepanel.message = promptBuild;
	
	if( [savepanel runModal] == NSFileHandlingPanelOKButton) {
		result = savepanel.URL;
		[MTProjectEditor sharedMTProjectEditor].currentProject.buildName = [result lastPathComponent];
	} else {
		[self operationResultWithTitle:@"Error" msgFormat:@"Build Operation Canceled" defaultButton:@"OK"];
	}
	
	return result;
}

- (NSString *)getHeader {
	NSString * result = [[MTProjectEditor sharedMTProjectEditor] getStoryFormat];
	
	if (result == nil || result.length == 0) {
		result = @"sugarcane";
	} else { // not checking the validity of header strings for now
		/*
		 NSURL * headerDirectory = [[MTPreferencesManager tweeDirectory] URLByDeletingLastPathComponent];
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
		 */
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
