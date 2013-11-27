//
//  Group.h
//  MacTwee
//
//  Created by Chris Braithwaite on 11/26/13.
//  Copyright (c) 2013 MacTwee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MTPassage, MTProject;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * color;
@property (nonatomic, retain) MTProject *project;
@property (nonatomic, retain) NSSet *passages;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addPassagesObject:(MTPassage *)value;
- (void)removePassagesObject:(MTPassage *)value;
- (void)addPassages:(NSSet *)values;
- (void)removePassages:(NSSet *)values;

@end
