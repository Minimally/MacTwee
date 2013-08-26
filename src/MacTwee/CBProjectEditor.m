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
////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

-(void)setCurrentProject:(CBProject *)proj {
	_currentProject = proj;
	_currentProject.lastModifiedDate = [NSDate date];
}
@end
