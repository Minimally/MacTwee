//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MTPassage, MTProject;


@interface MTPassage : NSManagedObject

@property (nonatomic, retain) NSNumber * buildable;
@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSNumber * locked;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSSet * incoming;
@property (nonatomic, retain) NSSet * outgoing;
@property (nonatomic, retain) MTProject * project;
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

@end
