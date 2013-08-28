/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"
@class CBPassage;
@class CBProject;

@interface CBProjectEditor : NSObject

CWL_DECLARE_SINGLETON_FOR_CLASS(CBProjectEditor);

@property (strong, nonatomic) CBProject * currentProject;
@property (strong, nonatomic) CBPassage * currentPassage;

- (void)createPassageWithTitle:(NSString *)title andTags:(NSString *)tags andText:(NSString *)text;
- (void)newPassage;
- (NSString *)getStoryFormat;
- (NSArray *)getPassages;
- (BOOL)checkPassageExistsInCurrentProject:(NSString *)passage;
- (BOOL)selectCurrentPassageWithName:(NSString *)passage;
@end
