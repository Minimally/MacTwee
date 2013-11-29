//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import "MTTweeExportUtility.h"
#import "MTProject.h"
#import "MTPassage.h"


@implementation MTTweeExportUtility


#pragma mark - Public

- (NSURL *)exportTweeFileFromProject:(MTProject *)project toDestination:(NSURL *)destination {
    NSAssert(project != nil, @"project is nil");
    NSAssert(destination != nil, @"destination is nil");
    
    NSURL * result;
    result = [self extractMethod:destination project:project silently:NO];
    return result;
}

- (NSURL *)exportScratchTweeFileFromProject:(MTProject *)project {
    NSAssert(project != nil, @"project is nil");
    NSURL * result;
    NSURL * destination = [self getScratchLocationForExport];
    result = [self extractMethod:destination project:project silently:YES];
    return result;
}


#pragma mark - Export - Passages To String

- (NSURL *)extractMethod:(NSURL *)destination project:(MTProject *)project silently:(BOOL)silently {
    NSURL * result = destination;
    NSString * sourceString;
    NSArray * passages = [project.passages allObjects];
    
    if (passages.count == 0) {
        [self operationResultWithTitle:@"Error" msgFormat:@"Couldn't find any passages to export" defaultButton:@"OK"];
        result = nil;
    }
    
    if (result != nil) {
        sourceString = [self passagesToString:passages];
    }
    
    if (sourceString == nil || sourceString.length == 0) {
        [self operationResultWithTitle:@"Error" msgFormat:@"Issue turning passages into a single string" defaultButton:@"OK"];
        result = nil;
    }
    
    if (result != nil) {
        NSError * error;
        if ( ![sourceString writeToURL:result atomically:YES encoding:NSUTF8StringEncoding error:&error] ) {
            [self operationResultWithTitle:@"Error" msgFormat:[NSString stringWithFormat:@"%@", error.localizedDescription] defaultButton:@"OK"];
            result = nil;
        } else {
            if ( !silently ) {
                [self operationResultWithTitle:@"Success" msgFormat:@"Export operation successful" defaultButton:@"OK"];
            }
        }
    }
    return result;
}

- (NSString *)passagesToString:(NSArray *)passages {
    NSAssert(passages != nil, @"passages NSArray is nil");
    NSAssert(passages.count > 0, @"passages count is 0");
    
	NSMutableString * result = [[NSMutableString alloc] init];
	
	for (MTPassage * passage  in passages) {
        NSString * stringPassage = [self passageToString:passage];
        [result appendString:stringPassage];
    }
    
	return result;
}

- (NSString *)passageToString:(MTPassage *)passage {
	NSString * string = @":: ";
	NSString * tags = @"";
	
	if (passage.passageTags != nil && passage.passageTags.length > 0) {
		tags = [NSString stringWithFormat:@"[%@]", passage.passageTags];
    }
	
	string = [string stringByAppendingFormat:@"%@ %@\n%@\n\n", passage.title, tags, passage.text];
	
	return string;
}


#pragma mark - Etc

- (NSURL *)runSavePanelForExport {
	NSURL * result;
	/*
	NSSavePanel *savepanel = [NSSavePanel savePanel];
	savepanel.canCreateDirectories = YES;
	savepanel.nameFieldStringValue = [MTProjectEditor sharedMTProjectEditor].currentProject.sourceName;
	savepanel.message = exportMessage;
	
	if( [savepanel runModal] == NSFileHandlingPanelOKButton) {
		result = savepanel.URL;
		NSLog(@"%s 'Line:%d' - resultURL:'%@'", __func__, __LINE__, result);
		[MTProjectEditor sharedMTProjectEditor].currentProject.sourceName = [result lastPathComponent];
	}
	*/
	return result;
}

- (NSURL *)getScratchLocationForExport {
	NSURL * result;
	NSFileManager * fileManager = [NSFileManager defaultManager];
    NSURL * appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
	NSString * tempPath = [NSString stringWithFormat:@"%@/temp.tw", kUserApplicationSupportDirectory];
    result = [appSupportURL URLByAppendingPathComponent:tempPath];
	return result;
}

- (void)operationResultWithTitle:(NSString *)title msgFormat:(NSString *)msgFormat defaultButton:(NSString *)defaultButton {
	NSRunAlertPanel(title, msgFormat, defaultButton, nil, nil);
	//[self operationResultWithTitle:@"Error" msgFormat:@"EXAMPLE" defaultButton:@"OK"];
	//[self operationResultWithTitle:@"Success" msgFormat:@"EXAMPLE" defaultButton:@"OK"];
}


@end
