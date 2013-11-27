//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import <Foundation/Foundation.h>


@interface MTTweeBuildUtility : NSObject

/*! Builds out an html file from tweecode source
 @param sourceFileURL NSURL source file
 @param buildDirectory NSString full path for the output file
 @param buildFileName NSString name of the output file
 @param storyFormat NSString name of the story format in the twee directory
 @param quickBuild BOOL skip prompts if possible
 */

- (BOOL)buildHtmlFileWithSource:(NSURL *)sourceFileURL
                      buildDirectory:(NSString *)buildDirectory
                  buildFileName:(NSString *)buildFileName
                    storyFormat:(NSString *)storyFormat
                    quickBuild:(BOOL)quickBuild;

@end
