//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import "MTTweeBuildUtility.h"
#import "NSString+PDRegex.h"
#import "MTPreferencesManager.h"
#import "MTProject.h"
#import "MTDialogues.h"


@interface MTTweeBuildUtility ()

/// allows a forcing prompt for save destination after build if set to true & should we display a success modal
@property BOOL quickBuild;

/// build destination
@property (strong) NSString * buildDirectory;

/// build destination
@property (strong) NSString * buildFileName;

/// build destination
@property (strong) NSString * storyFormat;

@end


@implementation MTTweeBuildUtility

NSString * const promptBuild = @"Choose build destination";
NSString * const promptTwee = @"Please select Twee terminal application";


#pragma mark - Public

- (BOOL)buildHtmlFileWithSource:(NSURL *)sourceFileURL
                 buildDirectory:(NSString *)buildDirectory
                  buildFileName:(NSString *)buildFileName
                    storyFormat:(NSString *)storyFormat
                     quickBuild:(BOOL)quickBuild {
    BOOL result = YES;
	
	if (sourceFileURL.path.length == 0) {
		[self operationResultWithTitle:@"Error" msgFormat:@"Empty Source File" defaultButton:@"OK"];
		result = NO;
	}
	
	if (buildDirectory.length == 0) {
		[self operationResultWithTitle:@"Error" msgFormat:[NSString stringWithFormat:@"Empty Build destination"] defaultButton:@"OK"];
		result = NO;
	} else {
        self.buildDirectory = buildDirectory;
    }
	
	if (buildFileName.length == 0) {
		[self operationResultWithTitle:@"Error" msgFormat:[NSString stringWithFormat:@"Empty build filename"] defaultButton:@"OK"];
		result = NO;
	} else {
        self.buildFileName = buildFileName;
    }
	
	if (result) {
		self.storyFormat = storyFormat;
        [self checkStoryFormat];
        
        self.quickBuild = quickBuild;
        
        [self buildTweeFileAtPath:sourceFileURL.path];
	}
	
    return result;
}


#pragma mark - Private

- (void)buildTweeFileAtPath:(NSString *)path {
	NSLog(@"%s 'Line:%d' - path:'%@' header:'%@'", __func__, __LINE__, path, self.storyFormat);
	NSAssert(path != nil, @"url is nil");
	
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
	task.arguments =  @[ @"-t", self.storyFormat, path, @">", @"irrelevant.html" ];
	task.standardOutput = outputPipe;
	task.standardInput = [NSPipe pipe];
	
	// we will use a notification for when the process is done
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buildOperationDone:) name:NSFileHandleReadToEndOfFileCompletionNotification object:[outputPipe fileHandleForReading]];
    [[outputPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
	
	[task launch];
	[task waitUntilExit];
}

- (void)buildOperationDone:(NSNotification *)notification {
	NSAssert(notification != nil, @"notification is nil");
	
	NSString * compiledHTMLString = [[NSString alloc] initWithData:[notification userInfo][NSFileHandleNotificationDataItem] encoding:NSUTF8StringEncoding];
	
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

- (void)htmlFileWithBuildResult:(NSString *)compiledHTMLString {
	NSAssert((compiledHTMLString != nil || compiledHTMLString.length > 0), @"string is nil or empty");
	NSURL * fileURL;
    
    if (!self.quickBuild) { // user must select save destination
        fileURL = [self getSaveDestination];
    }
    else { // try to get the saved project build destination
        fileURL = [NSURL fileURLWithPath:self.buildDirectory];
        
        if (fileURL == nil) {
            fileURL = [self getSaveDestination];
        }
    }
	
	
	if( fileURL != nil) {
		if ([compiledHTMLString writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
			//TODO:[MTProjectEditor sharedMTProjectEditor].currentProject.buildDirectory = fileURL.path;
            NSDictionary * dict = @{ @"index":fileURL.path };
            [[NSNotificationCenter defaultCenter] postNotificationName:MTTweeBuildUtilityDidGetProjectBuildDestination
                                                                object:self
                                                              userInfo:dict];
		}
        else {
			[self operationResultWithTitle:@"Error" msgFormat:[NSString stringWithFormat:@"issue writing html file string to url '%@'", fileURL] defaultButton:@"OK"];
		}
	}
    else {
        [self operationResultWithTitle:@"Error"
                             msgFormat:[NSString stringWithFormat:@"issue with save destination '%@'", self.buildDirectory]
                         defaultButton:@"OK"];
    }
}


#pragma mark - User Dialogues & Results

- (NSString *)getTwee {
	NSString * result;
    NSURL * urlToCheck;
	
	// try user defaults
	result = [[NSUserDefaults standardUserDefaults] stringForKey:kPathToTwee];
	urlToCheck = [NSURL fileURLWithPath:result isDirectory:NO];
	
	if ( ![[urlToCheck lastPathComponent] isEqualToString:@"twee"] ) {
		// prompt user
		urlToCheck = [self runPanelForTweeDirectory];
		if ( ![[urlToCheck lastPathComponent] isEqualToString:@"twee"] ) {
            // user failed us
			result = nil;
		}
        else {
            // user got it
			result = [urlToCheck path];
		}
	}
	
	return result;
}

// gets the user to specify a directory for twee
- (NSURL *)runPanelForTweeDirectory {
	NSURL * result = [MTDialogues openPanelForFileWithMessage:promptTwee];
	
	if ( result != nil ) {
		[[NSUserDefaults standardUserDefaults] setValue:[result path] forKey:kPathToTwee];
	} else {
		NSLog(@"%s 'Line:%d' - Operation Cancled by user or failed", __func__, __LINE__);
	}
	
	return result;
}

- (NSURL *)getSaveDestination {
	NSURL * result = [MTDialogues savePanelForDirectory:promptBuild fileName:self.buildFileName];
    
	if( result != nil ) {
		//TODO:[MTProjectEditor sharedMTProjectEditor].currentProject.buildName = [result lastPathComponent];
        NSDictionary * dict = @{ @"index":result.lastPathComponent };
        [[NSNotificationCenter defaultCenter] postNotificationName:MTTweeBuildUtilityDidGetProjectBuildName
                                                            object:self
                                                          userInfo:dict];
	} else {
		[self operationResultWithTitle:@"Error" msgFormat:@"Build Operation Canceled" defaultButton:@"OK"];
	}
	
	return result;
}

- (void)checkStoryFormat {
	if (self.storyFormat == nil || self.storyFormat.length == 0) {
		self.storyFormat = @"sugarcane";
	}
    else { // not checking the validity of header strings for now
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
}

/*! Called when the operation is complete
 Example: [self operationResultWithTitle:@"Error" msgFormat:@"EXAMPLE" defaultButton:@"OK"];
 Example: [self operationResultWithTitle:@"Success" msgFormat:@"EXAMPLE" defaultButton:@"OK"];
 */
- (void)operationResultWithTitle:(NSString *)title msgFormat:(NSString *)msgFormat defaultButton:(NSString *)defaultButton {
	NSLog(@"%s 'Line:%d' - msgFormat:'%@'", __func__, __LINE__, msgFormat);
	NSAssert(title != nil, @"title is nil");
	NSAssert(msgFormat != nil, @"msgFormat is nil");
	NSAssert(defaultButton != nil, @"defaultButton is nil");
    
    if ( [title isEqualToString:@"Success"] && !self.quickBuild ) {
        
    }
    else {
        NSRunAlertPanel(title, msgFormat, defaultButton, nil, nil);
    }
    
    // clear values
    self.quickBuild = YES;
    self.quickBuild = YES;
    self.buildDirectory = nil;
    self.buildFileName = nil;
    self.storyFormat = nil;
}


@end
