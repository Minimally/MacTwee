//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import <Foundation/Foundation.h>


@interface MTTweeBuildUtility : NSObject

- (void)buildHtmlFileWithSource:(NSURL *)url;

- (void)buildHtmlFileWithSource:(NSURL *)url andHeader:(NSString *)header;

@end
