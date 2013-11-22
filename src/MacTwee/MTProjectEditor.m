/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "MTProjectEditor.h"
#import "MTCoreDataManager.h"
#import "MTProject.h"
#import "MTPassage.h"

@implementation MTProjectEditor

#pragma mark - Lifecycle
CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(MTProjectEditor);

#pragma mark - Public
- (void)createPassageWithTitle:(NSString *)title andTags:(NSString *)tags andText:(NSString *)text {
	NSAssert(self.currentProject != nil, @"currentProject is nil");
	MTPassage * passage = (MTPassage *)[NSEntityDescription insertNewObjectForEntityForName:@"Passage"
																	 inManagedObjectContext:[MTCoreDataManager sharedMTCoreDataManager].managedObjectContext];
	passage.title = title;
	passage.tags = tags;
	passage.text = text;
	passage.project = self.currentProject;
}
- (void)newPassage {
	[self createPassageWithTitle:@"New Passage" andTags:@"" andText:@""];
}
- (NSString *)getStoryFormat {
	return self.currentProject.storyFormat;
}
- (NSArray *)getPassages {
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
	BOOL result = NO;
	
	NSArray * passages = [self getPassages];
	//NSLog(@"%s 'Line:%d' - passages count:'%lu'", __func__, __LINE__, passages.count);
	NSMutableArray * passageNames = [[NSMutableArray alloc]initWithCapacity:0];
	
	for (MTPassage * p in passages) {
		NSString * passageTitle = p.title;
		//NSLog(@"%s 'Line:%d' - passage title:'%@'", __func__, __LINE__, passageTitle);
		[passageNames addObject:passageTitle];
	}

	//NSLog(@"%s 'Line:%d' - passageNames count:'%lu'", __func__, __LINE__, passageNames.count);
	
	result = [passageNames containsObject:passage];
	
	return result;
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
#pragma mark - Private
- (void)setCurrentProject:(MTProject *)proj {
	_currentProject = proj;
	_currentProject.lastModifiedDate = [NSDate date];
}
- (void)setCurrentPassage:(MTPassage *)passage {
	[self willChangeValueForKey:@"currentPassage"];
	_currentPassage = nil;
	_currentPassage = passage;
	_currentPassage.lastModifiedDate = [NSDate date];
	[self didChangeValueForKey:@"currentPassage"];
}
- (MTPassage *)getPassageWithName:(NSString *)passage {
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
