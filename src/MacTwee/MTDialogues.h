//
//  MTDialogues.h
//  MacTwee
//
//  Created by Chris Braithwaite on 11/27/13.
//  Copyright (c) 2013 MacTwee. Released under MIT License.
//

#import <Foundation/Foundation.h>

/// global methods for open and save dialogues

@interface MTDialogues : NSObject

/*! Presents an open panel for a file
 @param message user displayed message
 @returns the absolute pathname of the file currently shown in the panel as a URL or nil if operation failed */
+ (NSURL *)openPanelForFileWithMessage:(NSString *)message;

/*! Presents a save panel for a file
 @param message message displayed in panel
 @param nameField name for the file being saved
 @returns the absolute pathname of the file currently shown in the panel as a URL or nil if operation failed */
+ (NSURL *)savePanelForFileWithMessage:(NSString *)message fileName:(NSString *)fileName;

@end
