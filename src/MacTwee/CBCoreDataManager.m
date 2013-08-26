/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBCoreDataManager.h"

@implementation CBCoreDataManager

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

NSString * const kManagedObjectModelURL = @"MacTwee";// managed object model path
NSString * const kManagedObjectModelExtension = @"momd";// managed object model extension
NSString * const kPersistantStorePath = @"MacTwee.sqlite";// store file path
NSString * const kErrorDomain = @"com.ChrisBraithwaite.MacTwee";

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(CBCoreDataManager);

//hack to prevent duplicate instances when loading from nib
+ (id)alloc {
	return [self sharedCBCoreDataManager];
}

- (id)init {
	return self;
}
//end hack

////////////////////////////////////////////////////////////////////////
#pragma mark - Protocol
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
#pragma mark - Public
////////////////////////////////////////////////////////////////////////

- (void)save {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)runTerminateByCoreDataFirst:(NSApplication *)sender {
	//NSLog(@"%s 'Line:%d' - sender:'%@'", __func__, __LINE__, sender);
	
    if (!_managedObjectContext) {
		NSLog(@"%s 'Line:%d' - No Managed Object Context", __func__, __LINE__);
		return NSTerminateNow;
	}
    
    if (![[self managedObjectContext] commitEditing]) {
		NSLog(@"%s 'Line:%d' - unable to commit editing to terminate", __func__, __LINE__);
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
		NSLog(@"%s 'Line:%d' - managed object context had no changes", __func__, __LINE__);
		return NSTerminateNow;
	}
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
		NSLog(@"%s 'Line:%d' - save error ", __func__, __LINE__);
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) { return NSTerminateCancel; }
		
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
		
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) { return NSTerminateCancel; }
    } else {
		//NSLog(@"%s 'Line:%d' - managed object context saved", __func__, __LINE__);
	}
	
	return NSTerminateNow;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:kErrorDomain code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
	
    return _managedObjectContext;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (NSURL *)applicationFilesDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:kUserApplicationSupportDirectory];
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kManagedObjectModelURL withExtension:kManagedObjectModelExtension];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
		NSLog(@"%s 'Line:%d' No model to generate a store from", __func__, __LINE__);
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:kErrorDomain code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
	NSDictionary * options = @{ NSMigratePersistentStoresAutomaticallyOption:[NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption:[NSNumber numberWithBool:YES] };
	
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:kPersistantStorePath];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

@end
