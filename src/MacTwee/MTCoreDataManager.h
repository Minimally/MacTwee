/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"

@interface MTCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

CWL_DECLARE_SINGLETON_FOR_CLASS(MTCoreDataManager);

- (void)save;
- (NSApplicationTerminateReply)runTerminateByCoreDataFirst:(NSApplication *)sender;
- (NSManagedObjectContext *)managedObjectContext;

@end