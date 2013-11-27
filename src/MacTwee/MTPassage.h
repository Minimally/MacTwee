//
//  MTPassage.h
//  MacTwee
//
//  Created by Chris Braithwaite on 11/26/13.
//  Copyright (c) 2013 MacTwee. Released under MIT License.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, MTPassage, MTProject, Tag;

@interface MTPassage : NSManagedObject

@property (nonatomic, retain) NSNumber * buildable;
@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSNumber * locked;
@property (nonatomic, retain) NSString * passageTags;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * xPosition;
@property (nonatomic, retain) NSNumber * yPosition;
@property (nonatomic, retain) NSSet *incoming;
@property (nonatomic, retain) NSSet *outgoing;
@property (nonatomic, retain) MTProject *project;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) NSSet *tags;
/// uses regex to create links within passage text
- (void)populateLinks;
+ (instancetype)passage;
@end

@interface MTPassage (CoreDataGeneratedAccessors)

- (void)addIncomingObject:(MTPassage *)value;
- (void)removeIncomingObject:(MTPassage *)value;
- (void)addIncoming:(NSSet *)values;
- (void)removeIncoming:(NSSet *)values;

- (void)addOutgoingObject:(MTPassage *)value;
- (void)removeOutgoingObject:(MTPassage *)value;
- (void)addOutgoing:(NSSet *)values;
- (void)removeOutgoing:(NSSet *)values;

- (void)addGroupsObject:(Group *)value;
- (void)removeGroupsObject:(Group *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
