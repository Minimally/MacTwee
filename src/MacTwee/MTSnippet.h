//
//  MTSnippet.h
//  MacTwee
//
//  Created by Chris Braithwaite on 11/26/13.
//  Copyright (c) 2013 MacTwee. Released under MIT License.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MTSnippet : NSManagedObject

@property (nonatomic, retain) NSNumber * owner;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * type;

@end
