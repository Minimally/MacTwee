//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"
@class MTPassage, MTProject;


/*! Handles editing the current project */

@interface MTProjectEditor : NSObject

CWL_DECLARE_SINGLETON_FOR_CLASS(MTProjectEditor);

@property (strong, nonatomic) MTProject * currentProject;
@property (strong, nonatomic) MTPassage * currentPassage;


/// adds a new blank passage to the currentProject

- (void)newPassage;

/// adds a new customized passage to the currentProject

- (MTPassage *)createPassageWithTitle:(NSString *)title andTags:(NSString *)tags andText:(NSString *)text;

/// @return the saved story format of the currentProject if any

- (NSString *)getStoryFormat;

/// @return NSArray with all passages in the currentProject

- (NSArray *)getPassages;

/// @return YES if sent in passage exists in the currentProject

- (BOOL)checkPassageExistsInCurrentProject:(NSString *)passage;

/*! attempts to set the currentPassage by searching for the sent in string in core data @param passage - title of the passage @returns YES if successful */

- (BOOL)selectCurrentPassageWithName:(NSString *)passage;

/// sets all current properties to nil

- (void)ResetCurrentValues;

/// setup current project

- (void)setupCurrentProject:(MTProject *)project;


@end
