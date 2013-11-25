//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import "MTProject.h"
#import "MTPassage.h"
#import "MTCoreDataManager.h"


@implementation MTProject

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
+ (instancetype)project {
    id result;
	
	result = [NSEntityDescription insertNewObjectForEntityForName:@"Project"
                                           inManagedObjectContext:[MTCoreDataManager sharedMTCoreDataManager].managedObjectContext];
	
	return result;
}
@end
