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

/*! try to skip prompts, and success alert */
@property BOOL quickBuild;

/*! destination for the html output*/
@property (strong) NSURL * buildDirectory;
/*! location of the the story source file (txt,twee,tw) */
@property (strong) NSURL * sourceFile;

/*! location of twee directory */
@property (strong) NSString * tweePath;
/*! name of the output file */
@property (strong) NSString * storyFormat;

@end


@implementation MTTweeBuildUtility

NSString * const promptBuild = @"Choose build destination";
NSString * const promptTwee = @"Please select Twee terminal application";
NSString * const kBuildFileName = @"Story.html";

#pragma mark - Public

- (BOOL)buildHtmlFileWithSource:(NSURL *)sourceFileURL buildDirectory:(NSURL *)buildDirectory storyFormat:(NSString *)storyFormat quickBuild:(BOOL)quickBuild {
    BOOL result = YES;
    self.quickBuild = quickBuild;
    
    [self verifyTwee];
	if (self.tweePath == nil || self.tweePath.length == 0) {
        [self operationResultWithTitle:@"Error" msgFormat:@"Twee Application Unavailable" defaultButton:@"OK"];
        result = NO;
    }
    
    if (result) {
        self.storyFormat = storyFormat;
        [self verifyStoryFormat];
    }
    
    if (result) {
        self.sourceFile = sourceFileURL;
        [self verifySourceFile];
        if ( self.sourceFile == nil ) {
            [self operationResultWithTitle:@"Error" msgFormat:@"Story Source File Unavailable" defaultButton:@"OK"];
            result = NO;
        }
    }
	
	if (result) {
        self.buildDirectory = buildDirectory;
        [self verifyBuildDirectory];
        if (self.buildDirectory == nil) {
            [self operationResultWithTitle:@"Error" msgFormat:@"HTML destination Unavailable" defaultButton:@"OK"];
            result = NO;
        }
	}
	
	if (result) {
        [self buildTweeFile];
	}
	
    return result;
}


#pragma mark - Verify Twee, Story Format, Source Location, Build Destination

/*! tries to find Twee and sets tweePath. Uses NSUserDefaults first, then prompts user if fails */
- (void)verifyTwee {
    NSURL * workURL;
    
    // check user defaults
    self.tweePath = [[NSUserDefaults standardUserDefaults] stringForKey:kPathToTwee];
    if (self.tweePath != nil) { workURL = [NSURL fileURLWithPath:self.tweePath isDirectory:NO]; }
    
    // prompt user
	if ( ![workURL.lastPathComponent isEqualToString:@"twee"] ) { // defaults failed us
		workURL = [MTDialogues openPanelForFileWithMessage:promptTwee];
        
		if ( ![workURL.lastPathComponent isEqualToString:@"twee"] ) { // user failed us
			self.tweePath = nil;
		}
        
        else { // user got it
			self.tweePath = workURL.path;
            // save the path for next build
            [[NSUserDefaults standardUserDefaults] setValue:self.tweePath forKey:kPathToTwee];
		}
	}
}

/*! tries to verify the storyformat. Checks the string first, then checks the directory */
- (void)verifyStoryFormat {
    // check for nil and empty
    if (self.storyFormat == nil || self.storyFormat.length == 0) {
		self.storyFormat = @"sugarcane";
        return;
	}
    
    /* // check for an existing folder [NOT DOING THIS FOR EFFICIENCY ACCORDING TO DOCS]
    else {
		if (self.tweePath != nil) {
            NSURL * workURL;
            workURL = [NSURL fileURLWithPath:self.tweePath isDirectory:NO];
            workURL = [workURL URLByDeletingLastPathComponent];
            workURL = [workURL URLByAppendingPathComponent:@"targets"];
            workURL = [workURL URLByAppendingPathComponent:self.storyFormat];
            NSError * error;
            if ( ![workURL checkResourceIsReachableAndReturnError:&error] ) {
                NSLog(@"%d | %s - story format issue:'%@':'%@'", __LINE__, __func__, workURL, error.localizedDescription);
                self.storyFormat = @"sugarcane";
            }
        }
	} */
}

/*! tries to verify the sourceFile. Checks the string first, then checks the directory */
- (void)verifySourceFile {
    // check the string for empty path
    if (self.sourceFile == nil) {
        return;
    }
    if (self.sourceFile.path.length == 0) {
        self.sourceFile = nil;
	}
    /* [NOT DOING THIS FOR EFFICIENCY ACCORDING TO DOCS]
     NSError * error;
     if ( ![self.sourceFile checkResourceIsReachableAndReturnError:&error] ) {
     NSLog(@"%d | %s - source file issue:'%@':'%@'", __LINE__, __func__, self.sourceFile, error.localizedDescription);
     self.sourceFile = nil;
     }
     */
}

/*! tries to find Twee and sets tweePath. Uses NSUserDefaults first, then prompts user if fails */
- (void)verifyBuildDirectory {
    BOOL ask = YES;
    
    if ( self.quickBuild ) {
        
        if ( self.buildDirectory == nil ) { // if there was nothing sent to us, we need to ask
            ask = YES;
        }
        else {
            ask = NO;
        }
//        else { // if something was sent in, see if the url is reachable
//            NSError * error;
//            if ( ![self.buildDirectory checkResourceIsReachableAndReturnError:&error] ) {
//                NSLog(@"%d | %s - checkResourceIsReachableAndReturnError failed:'%@':'%@'", __LINE__, __func__, self.buildDirectory, error.localizedDescription);
//                ask = YES;
//            }
//        }
    }
    
    if (ask) { // prompt user
        self.buildDirectory = [MTDialogues savePanelForFileWithMessage:promptBuild fileName:kBuildFileName];
    }
}


#pragma mark - Build

/*! create a task to build the source file using twee. posts a notification when complete. */

- (void)buildTweeFile {
	NSAssert(self.buildDirectory != nil, @"buildDirectory is nil");
	NSAssert(self.sourceFile != nil, @"sourceFile is nil");
	NSAssert(self.tweePath != nil, @"tweePath is nil");
	NSAssert(self.storyFormat != nil, @"storyFormat is nil");
	
	NSPipe *outputPipe;
	outputPipe = [NSPipe pipe];// we need to use a pipe to collect the data from twee build command
	
	NSTask *task;
	task = [[NSTask alloc] init];
	task.launchPath = self.tweePath; // where the process exists
	task.arguments =  @[ @"-t", self.storyFormat, self.sourceFile.path, @">", @"irrelevant.html" ];
	task.standardOutput = outputPipe;
	task.standardInput = [NSPipe pipe];
	
	// we will use a notification for when the process is done
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processIsDone:) name:NSFileHandleReadToEndOfFileCompletionNotification object:[outputPipe fileHandleForReading]];
    [[outputPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
	
	[task launch];
	[task waitUntilExit];
}

/*! notification recieved when the build task is complete. Contains the output of the task */

- (void)processIsDone:(NSNotification *)notification {
	NSAssert(notification != nil, @"notification is nil");
	
	NSString * compiledHTMLString = [[NSString alloc] initWithData:[notification userInfo][NSFileHandleNotificationDataItem] encoding:NSUTF8StringEncoding];
	
	if ( compiledHTMLString == nil || compiledHTMLString.length == 0 ) {
		[self operationResultWithTitle:@"Error" msgFormat:@"Twee build operation returned no output" defaultButton:@"OK"];
	}
    
    else {
		if ([compiledHTMLString matchesPatternRegexPattern:@"twee: no source files specified"]) {
			[self operationResultWithTitle:@"Error" msgFormat:@"twee: no source files specified" defaultButton:@"OK"];
		}
        else {
			[self createHtmlFileWithBuildOutput:compiledHTMLString];
		}
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSFileHandleReadToEndOfFileCompletionNotification
												  object:[notification object]];
}

/*! turns the html output from twee into a file */

- (void)createHtmlFileWithBuildOutput:(NSString *)compiledHTMLString {
	NSAssert((compiledHTMLString != nil || compiledHTMLString.length > 0), @"string is nil or empty");
    // write the file, but send a fail alert if there is a problem
    NSError * error;
    [compiledHTMLString writeToURL:self.buildDirectory atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if ( error != nil ) {
        [self operationResultWithTitle:@"Error" msgFormat:[NSString stringWithFormat:@"Couldn't write html file to destination:'%@'", self.buildDirectory] defaultButton:@"OK"];
    }
    else {
        NSDictionary * dict = @{ @"index":self.buildDirectory };
        [[NSNotificationCenter defaultCenter] postNotificationName:MTTweeBuildUtilityDidGetProjectBuildDestination
                                                            object:self
                                                          userInfo:dict];
    }
}

#pragma mark - Results

/*! Called when the operation is complete ( Error or Success )
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
    self.storyFormat = nil;
}


@end
