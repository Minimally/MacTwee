//
//  Tag.h
//  MacTwee
//
//  Created by Chris Braithwaite on 11/26/13.
//  Copyright (c) 2013 MacTwee. Released under MIT License.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MTPassage, MTProject;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * color;
@property (nonatomic, retain) NSSet *passages;
@property (nonatomic, retain) MTProject *project;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addPassagesObject:(MTPassage *)value;
- (void)removePassagesObject:(MTPassage *)value;
- (void)addPassages:(NSSet *)values;
- (void)removePassages:(NSSet *)values;

@end
