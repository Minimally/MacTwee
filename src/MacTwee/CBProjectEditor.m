/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBProjectEditor.h"
#import "CBCoreDataManager.h"
#import "CBProject.h"
#import "CBPassage.h"

@implementation CBProjectEditor

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////
CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(CBProjectEditor);

////////////////////////////////////////////////////////////////////////
#pragma mark - Public
////////////////////////////////////////////////////////////////////////
- (void)createPassageWithTitle:(NSString *)title andTags:(NSString *)tags andText:(NSString *)text {
	NSAssert(self.currentProject != nil, @"currentProject is nil");
	CBPassage * passage = (CBPassage *)[NSEntityDescription insertNewObjectForEntityForName:@"Passage"
																	 inManagedObjectContext:[CBCoreDataManager sharedCBCoreDataManager].managedObjectContext];
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
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"project = %@", self.currentProject];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Passage"
											  inManagedObjectContext:CBCoreDataManager.sharedCBCoreDataManager.managedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	return [CBCoreDataManager.sharedCBCoreDataManager.managedObjectContext executeFetchRequest:fetchRequest
																						 error:&error];
}
- (BOOL)checkPassageExistsInCurrentProject:(NSString *)passage {
	BOOL result = NO;
	
	NSArray * passages = [self getPassages];
	//NSLog(@"%s 'Line:%d' - passages count:'%lu'", __func__, __LINE__, passages.count);
	NSMutableArray * passageNames = [[NSMutableArray alloc]initWithCapacity:0];
	
	for (CBPassage * p in passages) {
		NSString * passageTitle = p.title;
		//NSLog(@"%s 'Line:%d' - passage title:'%@'", __func__, __LINE__, passageTitle);
		[passageNames addObject:passageTitle];
	}

	//NSLog(@"%s 'Line:%d' - passageNames count:'%lu'", __func__, __LINE__, passageNames.count);
	
	result = [passageNames containsObject:passage];
	
	return result;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////
-(void)setCurrentProject:(CBProject *)proj {
	_currentProject = proj;
	_currentProject.lastModifiedDate = [NSDate date];
}

@end
