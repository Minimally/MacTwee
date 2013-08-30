//
//  CBPassage.h
//  MacTwee
//
//  Created by CGB on 8/28/13.
//  Copyright (c) 2013 Chris Braithwaite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CBPassage, CBProject;

@interface CBPassage : NSManagedObject

@property (nonatomic, retain) NSNumber * buildable;
@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSNumber * locked;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSSet *incoming;
@property (nonatomic, retain) NSSet *outgoing;
@property (nonatomic, retain) CBProject *project;
@end

@interface CBPassage (CoreDataGeneratedAccessors)

- (void)addIncomingObject:(CBPassage *)value;
- (void)removeIncomingObject:(CBPassage *)value;
- (void)addIncoming:(NSSet *)values;
- (void)removeIncoming:(NSSet *)values;

- (void)addOutgoingObject:(CBPassage *)value;
- (void)removeOutgoingObject:(CBPassage *)value;
- (void)addOutgoing:(NSSet *)values;
- (void)removeOutgoing:(NSSet *)values;

@end
