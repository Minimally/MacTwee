//
//  CBProject.h
//  MacTwee
//
//  Created by CGB on 8/28/13.
//  Copyright (c) 2013 Chris Braithwaite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CBPassage;

@interface CBProject : NSManagedObject

@property (nonatomic, retain) NSString * buildDirectory;
@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSString * projectName;
@property (nonatomic, retain) NSString * sourceDirectory;
@property (nonatomic, retain) NSString * storyAuthor;
@property (nonatomic, retain) NSString * storyFormat;
@property (nonatomic, retain) NSString * storyTitle;
@property (nonatomic, retain) NSSet *passages;
@end

@interface CBProject (CoreDataGeneratedAccessors)

- (void)addPassagesObject:(CBPassage *)value;
- (void)removePassagesObject:(CBPassage *)value;
- (void)addPassages:(NSSet *)values;
- (void)removePassages:(NSSet *)values;

@end
