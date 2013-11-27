//
//  MTSnippet.h
//  MacTwee
//
//  Created by Chris Braithwaite on 11/26/13.
//  Copyright (c) 2013 MacTwee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MTSnippet : NSManagedObject

@property (nonatomic, retain) NSNumber * owner;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * type;

@end
