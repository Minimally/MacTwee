//
//  MTProject.h
//  MacTwee
//
//  Created by Chris Braithwaite on 11/26/13.
//  Copyright (c) 2013 MacTwee. Released under MIT License.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, MTPassage;

@interface MTProject : NSManagedObject

@property (nonatomic, retain) NSString * buildDirectory;
@property (nonatomic, retain) NSString * buildName;
@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSString * projectName;
@property (nonatomic, retain) NSString * sourceDirectory;
@property (nonatomic, retain) NSString * sourceName;
@property (nonatomic, retain) NSString * storyAuthor;
@property (nonatomic, retain) NSString * storyFormat;
@property (nonatomic, retain) NSString * storyTitle;
@property (nonatomic, retain) NSSet *passages;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) NSSet *tags;
//
+ (instancetype)project;
@end

@interface MTProject (CoreDataGeneratedAccessors)

- (void)addPassagesObject:(MTPassage *)value;
- (void)removePassagesObject:(MTPassage *)value;
- (void)addPassages:(NSSet *)values;
- (void)removePassages:(NSSet *)values;

- (void)addGroupsObject:(Group *)value;
- (void)removeGroupsObject:(Group *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
