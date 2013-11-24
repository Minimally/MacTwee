//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"


/*! Handles Core Data operations */

@interface MTCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel * managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext * managedObjectContext;

CWL_DECLARE_SINGLETON_FOR_CLASS(MTCoreDataManager);

- (void)save;
- (NSApplicationTerminateReply)runTerminateByCoreDataFirst:(NSApplication *)sender;
- (NSManagedObjectContext *)managedObjectContext;
- (NSArray *)executeFetchWithPredicate:(NSPredicate *)predicate entity:(NSString *)entityString;

@end
