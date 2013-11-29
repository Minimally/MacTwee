//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import <Foundation/Foundation.h>


@interface MTTweeBuildUtility : NSObject

/*! Builds out an html file from tweecode source
 @param sourceFileURL NSURL location of the source file
 @param buildDirectory NSURL location for the output file
 @param storyFormat NSString name of the story format in the twee directory
 @param quickBuild BOOL skip prompts if possible
 */

- (BOOL)buildHtmlFileWithSource:(NSURL *)sourceFileURL
                 buildDirectory:(NSURL *)buildDirectory
                    storyFormat:(NSString *)storyFormat
                     quickBuild:(BOOL)quickBuild;

@end
