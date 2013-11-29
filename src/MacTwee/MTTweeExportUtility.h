//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import <Foundation/Foundation.h>
@class MTProject;

@interface MTTweeExportUtility : NSObject

/*! exports project to .twee file
 @param project MTProject project
 @param destination NSURL location to save to
 @returns the result file NSURL or nil if failed
 */
- (NSURL *)exportTweeFileFromProject:(MTProject *)project toDestination:(NSURL *)destination;

/*! exports project to .twee file in scratch directory
 @param project MTProject project
 @returns the result file NSURL or nil if failed
 */
- (NSURL *)exportScratchTweeFileFromProject:(MTProject *)project;

@end
