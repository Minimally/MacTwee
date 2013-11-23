
#import "MTProjectEditor.h"
#import "MTCoreDataManager.h"
#import "MTProject.h"
#import "MTPassage.h"


@implementation MTProjectEditor

#pragma mark - Lifecycle

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(MTProjectEditor);


#pragma mark - Public

- (void)newPassage {
	NSAssert(self.currentProject != nil, @"currentProject is nil");
	[self createPassageWithTitle:@"New Passage" andTags:@"" andText:@""];
}

- (void)createPassageWithTitle:(NSString *)title andTags:(NSString *)tags andText:(NSString *)text {
	NSAssert(self.currentProject != nil, @"currentProject is nil");
	MTPassage * passage = (MTPassage *)[NSEntityDescription insertNewObjectForEntityForName:@"Passage"
																	 inManagedObjectContext:[MTCoreDataManager sharedMTCoreDataManager].managedObjectContext];
	passage.title = title;
	passage.tags = tags;
	passage.text = text;
	passage.project = self.currentProject;
}

- (NSString *)getStoryFormat {
	NSAssert(self.currentProject != nil, @"currentProject is nil");
	return self.currentProject.storyFormat;
}

- (NSArray *)getPassages {
	NSAssert(self.currentProject != nil, @"currentProject is nil");
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"project == %@", self.currentProject];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Passage"
											  inManagedObjectContext:MTCoreDataManager.sharedMTCoreDataManager.managedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	return [MTCoreDataManager.sharedMTCoreDataManager.managedObjectContext executeFetchRequest:fetchRequest
																						 error:&error];
}

- (BOOL)checkPassageExistsInCurrentProject:(NSString *)passage {
    return ([self getPassageWithName:passage] == nil) ? NO : YES;
}

- (BOOL)selectCurrentPassageWithName:(NSString *)passage {
	BOOL result = NO;
	
	if ( ![self checkPassageExistsInCurrentProject:passage] ) {
		result = NO;
	} else {
		MTPassage * p = [self getPassageWithName:passage];
		if (p != nil) {
			self.currentPassage = p;
			result = YES;
		}
	}
	
	return result;
}

- (void)ResetCurrentValues {
    self.currentProject = nil;
    self.currentPassage = nil;
}

#pragma mark - Private

- (void)setCurrentProject:(MTProject *)proj {
	_currentProject = proj;
	_currentProject.lastModifiedDate = [NSDate date];
}

- (void)setCurrentPassage:(MTPassage *)passage {
	[self willChangeValueForKey:@"currentPassage"];
    _currentPassage = nil;
    if ( passage != nil ) {
        _currentPassage = passage;
        _currentPassage.lastModifiedDate = [NSDate date];
    }
	[self didChangeValueForKey:@"currentPassage"];
}

/*! searches for a MTPassage using the sent in string in core data @param passage - title of the passage @returns an MTPassage if successful else nil */

- (MTPassage *)getPassageWithName:(NSString *)passage {
	NSAssert(self.currentProject != nil, @"currentProject is nil");
	MTPassage * p;
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(title == %@) AND (project == %@)", passage, self.currentProject];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Passage"
											  inManagedObjectContext:MTCoreDataManager.sharedMTCoreDataManager.managedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	NSArray * foundPassages = [MTCoreDataManager.sharedMTCoreDataManager.managedObjectContext executeFetchRequest:fetchRequest
																											error:&error];
	//NSLog(@"%s 'Line:%d' - found:'%lu'", __func__, __LINE__, foundPassages.count);
	if (foundPassages.count >= 1) {
		p = foundPassages[0];
	}
	return p;
}


@end
