
#import "MTTweeExportUtility.h"
#import "MTPreferencesManager.h"
#import "MTCoreDataManager.h"
#import "MTProjectEditor.h"
#import "MTProject.h"
#import "MTPassage.h"


@implementation MTTweeExportUtility

NSString * const exportMessage = @"Choose export destination";


#pragma mark - Public

- (NSURL *)exportTweeFile {
	NSURL * result = [self runSavePanelForExport];
	if (result == nil) {
		[self operationResultWithTitle:@"Error" msgFormat:@"Export operation canceled" defaultButton:@"OK"];
	} else {
		
		NSArray * fetchedObjects = [[MTProjectEditor sharedMTProjectEditor] getPassages];
		if (fetchedObjects == nil || fetchedObjects.count < 1) {
			[self operationResultWithTitle:@"Error" msgFormat:@"Couldn't find any passages to export" defaultButton:@"OK"];
		} else {
			
			NSString * sourceString = [self getCombinedPassagesString:fetchedObjects];
			if (sourceString == nil || sourceString.length < 1) {
				[self operationResultWithTitle:@"Error" msgFormat:@"Issue turning passages into a single string" defaultButton:@"OK"];
			} else {
				
				NSError * error;
				if ( ! [sourceString writeToURL:result atomically:YES encoding:NSUTF8StringEncoding error:&error] ) {
					[self operationResultWithTitle:@"Error" msgFormat:[NSString stringWithFormat:@"%@", error.localizedDescription] defaultButton:@"OK"];
				} else {
					[self operationResultWithTitle:@"Success" msgFormat:@"Export operation successful" defaultButton:@"OK"];
				}
			}
		}
	}
	return result;
}

- (NSURL *)exportTempTweeFile {
	NSArray * fetchedObjects = [[MTProjectEditor sharedMTProjectEditor] getPassages];
	NSString * sourceString = [self getCombinedPassagesString:fetchedObjects];
	
	NSURL * result = [self getScratchLocationForExport];
	if (result != nil)
		[sourceString writeToURL:result atomically:YES encoding:NSUTF8StringEncoding error:nil];
	return result;
}


#pragma mark - Export - Passages To String

- (NSString *)getCombinedPassagesString:(NSArray *)fetchedObjects {
	NSMutableString * combinedPassages = [[NSMutableString alloc] init];
	
	if (fetchedObjects == nil) {
		//NSLog(@"%s 'Line:%d' 'nothing back from fetch'", __func__, __LINE__);
	} else {
		//NSLog(@"%s 'Line:%d' - fetchedObjects count:'%lu'", __func__, __LINE__, fetchedObjects.count);
		for (MTPassage * passage  in fetchedObjects) {
			//NSLog(@"%s 'Line:%d' - passage.title:'%@'", __func__, __LINE__, passage.title);
			NSString * stringPassage = [self passageToString:passage];
			[combinedPassages appendString:stringPassage];
		}
	}
	
	//NSLog(@"%s 'Line:%d' - combinedPassages:'%@'", __func__, __LINE__, combinedPassages);
	return combinedPassages;
}

- (NSString *)passageToString:(MTPassage *)passage {
	NSString * string = @":: ";
	NSString * tags = @"";
	
	if (passage.tags != nil && passage.tags.length > 0)
		tags = [NSString stringWithFormat:@"[%@]", passage.tags];
	
	string = [string stringByAppendingFormat:@"%@ %@\n%@\n\n", passage.title, tags, passage.text];
	
	return string;
}


#pragma mark - User Dialogues

- (NSURL *)runSavePanelForExport {
	NSURL * result;
	
	NSSavePanel *savepanel = [NSSavePanel savePanel];
	savepanel.canCreateDirectories = YES;
	savepanel.nameFieldStringValue = [MTProjectEditor sharedMTProjectEditor].currentProject.sourceName;
	savepanel.message = exportMessage;
	
	if( [savepanel runModal] == NSFileHandlingPanelOKButton) {
		result = savepanel.URL;
		NSLog(@"%s 'Line:%d' - resultURL:'%@'", __func__, __LINE__, result);
		[MTProjectEditor sharedMTProjectEditor].currentProject.sourceName = [result lastPathComponent];
	}
	
	return result;
}

- (NSURL *) getScratchLocationForExport {
	NSURL * result;
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
	NSString * tempPath = [NSString stringWithFormat:@"%@/temp.tw", kUserApplicationSupportDirectory];
    result = [appSupportURL URLByAppendingPathComponent:tempPath];
	//	result = [[MTPreferencesManager documentDirectory] URLByAppendingPathComponent:@"temp.tw"];
	//	NSLog(@"%s 'Line:%d' - result:'%@'", __func__, __LINE__, result);
	return result;
}

- (void)operationResultWithTitle:(NSString *)title msgFormat:(NSString *)msgFormat defaultButton:(NSString *)defaultButton {
	NSRunAlertPanel(title, msgFormat, defaultButton, nil, nil);
	//[self operationResultWithTitle:@"Error" msgFormat:@"EXAMPLE" defaultButton:@"OK"];
	//[self operationResultWithTitle:@"Success" msgFormat:@"EXAMPLE" defaultButton:@"OK"];
}


@end
