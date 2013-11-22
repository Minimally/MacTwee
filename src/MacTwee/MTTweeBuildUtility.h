/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface MTTweeBuildUtility : NSObject
- (void)buildHtmlFileWithSource:(NSURL *)url;
- (void)buildHtmlFileWithSource:(NSURL *)url andHeader:(NSString *)header;
@end