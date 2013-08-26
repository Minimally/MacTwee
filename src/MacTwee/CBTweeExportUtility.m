/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBTweeExportUtility.h"
#import "CBPreferencesManager.h"
#import "CBCoreDataManager.h"
#import "CBProjectEditor.h"
#import "CBPassage.h"
#import "CBProject.h"

@implementation CBTweeExportUtility

NSString * const exportMessage = @"Choose export destination";

////////////////////////////////////////////////////////////////////////
#pragma mark - Public
////////////////////////////////////////////////////////////////////////

- (NSURL *)exportTweeFile {
	NSArray * fetchedObjects = [self getPassages];
	NSString * sourceString = [self getCombinedPassagesString:fetchedObjects];
	
	NSURL * result = [self runSavePanelForExport];
	if (result != nil)
		[sourceString writeToURL:result atomically:YES encoding:NSUTF8StringEncoding error:nil];
	return result;
}

- (NSURL *)exportTempTweeFile {
	NSArray * fetchedObjects = [self getPassages];
	NSString * sourceString = [self getCombinedPassagesString:fetchedObjects];
	
	NSURL * result = [self getScratchLocationForExport];
	if (result != nil)
		[sourceString writeToURL:result atomically:YES encoding:NSUTF8StringEncoding error:nil];
	return result;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Export - Passages To String
////////////////////////////////////////////////////////////////////////
- (NSArray *)getPassages {
	id currentProject = [[CBProjectEditor sharedCBProjectEditor] currentProject];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"project = %@", currentProject];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Passage"
											  inManagedObjectContext:CBCoreDataManager.sharedCBCoreDataManager.managedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	return [CBCoreDataManager.sharedCBCoreDataManager.managedObjectContext executeFetchRequest:fetchRequest
																						 error:&error];
}
- (NSString *)getCombinedPassagesString:(NSArray *)fetchedObjects {
	NSMutableString * combinedPassages = [[NSMutableString alloc] init];
	
	if (fetchedObjects == nil) {
		//NSLog(@"%s 'Line:%d' 'nothing back from fetch'", __func__, __LINE__);
	} else {
		//NSLog(@"%s 'Line:%d' - fetchedObjects count:'%lu'", __func__, __LINE__, fetchedObjects.count);
		for (CBPassage * passage  in fetchedObjects) {
			//NSLog(@"%s 'Line:%d' - passage.title:'%@'", __func__, __LINE__, passage.title);
			NSString * stringPassage = [self passageToString:passage];
			[combinedPassages appendString:stringPassage];
		}
	}
	
	//NSLog(@"%s 'Line:%d' - combinedPassages:'%@'", __func__, __LINE__, combinedPassages);
	return combinedPassages;
}
- (NSString *)passageToString:(CBPassage *)passage {
	NSString * string = @":: ";
	NSString * tags = @"";
	
	if (passage.tags != nil && passage.tags.length > 0)
		tags = [NSString stringWithFormat:@"[%@]", passage.tags];
	
	string = [string stringByAppendingFormat:@"%@ %@\n%@\n\n", passage.title, tags, passage.text];
	
	return string;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - User Dialogues
////////////////////////////////////////////////////////////////////////
- (NSURL *)runSavePanelForExport {
	NSURL * result;
	
	NSSavePanel *savepanel = [NSSavePanel savePanel];
	savepanel.canCreateDirectories = YES;
	savepanel.nameFieldStringValue = [CBPreferencesManager lastSourceName];
	savepanel.message = exportMessage;
	
	if( [savepanel runModal] == NSFileHandlingPanelOKButton) {
		result = savepanel.URL;
		NSLog(@"%s 'Line:%d' - resultURL:'%@'", __func__, __LINE__, result);
		[CBPreferencesManager setLastSourceName:[result lastPathComponent]];
	} else {
		NSLog(@"%s 'Line:%d' - Operation Cancled by user", __func__, __LINE__);
	}
	
	return result;
}
- (NSURL *) getScratchLocationForExport {
	NSURL * result;
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
	NSString * tempPath = [NSString stringWithFormat:@"%@/temp.tw", kUserApplicationSupportDirectory];
    result = [appSupportURL URLByAppendingPathComponent:tempPath];
	//	result = [[CBPreferencesManager documentDirectory] URLByAppendingPathComponent:@"temp.tw"];
	//	NSLog(@"%s 'Line:%d' - result:'%@'", __func__, __LINE__, result);
	return result;
}
@end
