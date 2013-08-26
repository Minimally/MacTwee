/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CBProject;

@interface CBPassage : NSManagedObject

@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * locked;
@property (nonatomic, retain) NSNumber * build;
@property (nonatomic, retain) CBProject *project;

@end
