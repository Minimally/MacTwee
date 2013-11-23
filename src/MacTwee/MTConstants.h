
#import <Foundation/Foundation.h>


@interface MTConstants : NSObject

typedef enum {
    MTPageHome = 0,
    MTPageProject
} MTPage;

#pragma mark - notifications

extern NSString * const MTPrimaryWindowControllerWillOpenViewNotification;

/// triggered when user alt clicks a link in the text view
extern NSString * const MTTextViewControllerDidGetPotentialPassageClickNotification;

#pragma mark - paths

extern NSString * const kOpenPath;
extern NSString * const kSavePath;
extern NSString * const kPathToTwee;

#pragma mark - assorted strings

extern NSString * const kdefaultBuildName;
extern NSString * const kdefaultSourceName;
extern NSString * const kUserApplicationSupportDirectory;
extern NSString * const kLinkMatch;

@end
