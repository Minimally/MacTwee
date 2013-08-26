/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface CBTweeFileTools : NSObject

- (void)importTweeFile;
- (NSURL *)exportTweeFile;

- (void)buildStory;
- (void)buildAndRunStory;

@end
