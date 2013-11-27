//
//  MTProject.m
//  MacTwee
//
//  Created by Chris Braithwaite on 11/26/13.
//  Copyright (c) 2013 MacTwee. All rights reserved.
//

#import "MTProject.h"
#import "Group.h"
#import "MTPassage.h"
#import "MTCoreDataManager.h"


@implementation MTProject

@dynamic buildDirectory;
@dynamic buildName;
@dynamic lastModifiedDate;
@dynamic projectName;
@dynamic sourceDirectory;
@dynamic sourceName;
@dynamic storyAuthor;
@dynamic storyFormat;
@dynamic storyTitle;
@dynamic passages;
@dynamic groups;
@dynamic tags;
//
- (void) awakeFromInsert
{
    [super awakeFromInsert];
    self.lastModifiedDate = [NSDate date];
    self.buildName = kdefaultBuildName;
	self.sourceName = kdefaultSourceName;
}
+ (instancetype)project {
    id result;
	
	result = [NSEntityDescription insertNewObjectForEntityForName:@"Project"
                                           inManagedObjectContext:[MTCoreDataManager sharedMTCoreDataManager].managedObjectContext];
	
	return result;
}
@end
