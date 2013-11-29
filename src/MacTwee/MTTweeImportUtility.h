//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import <Foundation/Foundation.h>
@class MTProject;

@interface MTTweeImportUtility : NSObject

/*! imports .twee/.txt/.tw file to project.
 @param project MTProject project
 @returns the number of passages imported
 */

- (int)importTweeFile:(NSURL *)file toProject:(MTProject *)project;

@end
