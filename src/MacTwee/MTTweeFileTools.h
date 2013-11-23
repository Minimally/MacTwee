//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import <Foundation/Foundation.h>


/*! Does Twee operations */

@interface MTTweeFileTools : NSObject

- (void)importTweeFile;
- (NSURL *)exportTweeFile;

- (void)buildStory;
- (void)buildAndRunStory;

@end
