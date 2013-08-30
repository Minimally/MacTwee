/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBProject.h"
#import "CBPassage.h"


@implementation CBProject

@dynamic buildDirectory;
@dynamic lastModifiedDate;
@dynamic projectName;
@dynamic sourceDirectory;
@dynamic storyAuthor;
@dynamic storyFormat;
@dynamic storyTitle;
@dynamic buildName;
@dynamic sourceName;
@dynamic passages;

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    self.lastModifiedDate = [NSDate date];
    self.buildName = kdefaultBuildName;
	self.sourceName = kdefaultSourceName;
}

@end
