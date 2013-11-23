
#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"
@class MTPassage, MTProject;


/*! Handles editing the current project */

@interface MTProjectEditor : NSObject

CWL_DECLARE_SINGLETON_FOR_CLASS(MTProjectEditor);

@property (strong, nonatomic) MTProject * currentProject;
@property (strong, nonatomic) MTPassage * currentPassage;

- (void)createPassageWithTitle:(NSString *)title andTags:(NSString *)tags andText:(NSString *)text;
- (void)newPassage;
- (NSString *)getStoryFormat;
- (NSArray *)getPassages;
- (BOOL)checkPassageExistsInCurrentProject:(NSString *)passage;
- (BOOL)selectCurrentPassageWithName:(NSString *)passage;

@end
